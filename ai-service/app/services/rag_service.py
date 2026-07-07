import os
import json
import requests
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.tools import tool
from app.utils.mongodb_client import get_db
import base64
import io
from PyPDF2 import PdfReader

# Initialize Gemini Chat Model
llm = ChatGoogleGenerativeAI(
    model="gemini-3.1-flash-lite",
    temperature=0.3,
    max_output_tokens=1024,
    google_api_key=os.getenv("GEMINI_API_KEY")
)

@tool
async def search_database_papers(query: str) -> str:
    """Search for relevant academic papers in the local MongoDB database. 
    Use this first to find papers already in the system.
    """
    db = await get_db()
    
    papers = []
    try:
        cursor = db.paper.find(
            {"$text": {"$search": query}},
            {"score": {"$meta": "textScore"}, "title": 1, "abstract": 1, "publicationYear": 1, "doi": 1, "url": 1}
        ).sort([("score", {"$meta": "textScore"})]).limit(5)
        papers = await cursor.to_list(length=5)
    except Exception as e:
        print(f"MongoDB text search error (likely missing index): {e}")
        papers = []

    if not papers:
        # Fallback to regex if text index is missing or no results
        try:
            cursor = db.paper.find(
                {"title": {"$regex": query, "$options": "i"}},
                {"title": 1, "abstract": 1, "publicationYear": 1, "doi": 1, "url": 1}
            ).limit(5)
            papers = await cursor.to_list(length=5)
        except Exception as fallback_e:
            print(f"MongoDB regex search error: {fallback_e}")
            papers = []

    if not papers:
        return "No relevant papers found in the local database."
    
    result = []
    for p in papers:
        doi = p.get('doi')
        url_link = p.get('url') or (f"https://doi.org/{doi}" if doi else "No URL available")
        result.append(f"Title: {p.get('title')}\nYear: {p.get('publicationYear')}\nDOI: {doi}\nURL: {url_link}\nAbstract: {p.get('abstract')}")
    
    return "\n\n---\n\n".join(result)

@tool
def search_openalex(query: str, limit: int = 5) -> str:
    """Search the OpenAlex API for external academic papers. 
    Use this to find highly relevant and recent papers globally.
    You can specify the number of papers to retrieve using the limit parameter (default 5).
    """
    try:
        res = requests.get(f"https://api.openalex.org/works?search={query}&per-page={limit}").json()
        results = []
        for r in res.get("results", []):
            title = r.get("title")
            authors = ", ".join([a.get("author", {}).get("display_name", "") for a in r.get("authorships", [])])
            year = r.get("publication_year")
            url = r.get("doi") or r.get("id")
            # OpenAlex returns abstract as an inverted index
            abstract = "Abstract available on source"
            if r.get("abstract_inverted_index"):
                inv_idx = r.get("abstract_inverted_index")
                words = max([max(positions) for positions in inv_idx.values()]) + 1
                abstract_arr = [""] * words
                for word, positions in inv_idx.items():
                    for pos in positions:
                        abstract_arr[pos] = word
                abstract = " ".join(abstract_arr)

            results.append(f"Title: {title}\nAuthors: {authors}\nPublished: {year}\nURL: {url}\nAbstract: {abstract}")
        if not results:
            return "No relevant papers found on OpenAlex."
        return "\n\n---\n\n".join(results)
    except Exception as e:
        return f"Error fetching from OpenAlex: {e}"

@tool
def search_semantic_scholar(query: str, limit: int = 5) -> str:
    """Search the Semantic Scholar API for external academic papers. 
    Use this to find high-impact academic papers with summaries.
    You can specify the number of papers to retrieve using the limit parameter (default 5).
    """
    try:
        url = f"https://api.semanticscholar.org/graph/v1/paper/search?query={query}&limit={limit}&fields=title,authors,year,url,abstract"
        res = requests.get(url).json()
        results = []
        for r in res.get("data", []):
            title = r.get("title")
            authors = ", ".join([a.get("name", "") for a in r.get("authors", [])])
            year = r.get("year")
            url_link = r.get("url")
            abstract = r.get("abstract") or "No abstract provided."
            results.append(f"Title: {title}\nAuthors: {authors}\nPublished: {year}\nURL: {url_link}\nAbstract: {abstract}")
        if not results:
            return "No relevant papers found on Semantic Scholar."
        return "\n\n---\n\n".join(results)
    except Exception as e:
        return f"Error fetching from Semantic Scholar: {e}"

@tool
def search_crossref(query: str, limit: int = 5) -> str:
    """Search the Crossref API for external academic papers. 
    Use this for fetching highly structured metadata from publishers.
    You can specify the number of papers to retrieve using the limit parameter (default 5).
    """
    try:
        url = f"https://api.crossref.org/works?query={query}&select=title,author,published,URL,abstract&rows={limit}"
        res = requests.get(url).json()
        results = []
        for r in res.get("message", {}).get("items", []):
            title = r.get("title", [""])[0]
            authors = ", ".join([f"{a.get('given', '')} {a.get('family', '')}".strip() for a in r.get("author", [])])
            year_arr = r.get("published", {}).get("date-parts", [[None]])[0]
            year = year_arr[0] if year_arr else "Unknown"
            url_link = r.get("URL")
            abstract = r.get("abstract") or "No abstract provided."
            results.append(f"Title: {title}\nAuthors: {authors}\nPublished: {year}\nURL: {url_link}\nAbstract: {abstract}")
        if not results:
            return "No relevant papers found on Crossref."
        return "\n\n---\n\n".join(results)
    except Exception as e:
        return f"Error fetching from Crossref: {e}"

from bson import ObjectId
from langchain.prompts import PromptTemplate
from langchain.agents import create_react_agent, AgentExecutor
from bson.errors import InvalidId
import contextvars

current_user_id = contextvars.ContextVar('current_user_id', default=None)

def get_clean_object_id():
    user_id = current_user_id.get()
    if not user_id or user_id == "Not logged in": return None
    clean_id = str(user_id).strip(" '\"")
    try:
        return ObjectId(clean_id)
    except InvalidId:
        return None

@tool
async def get_user_workspaces(dummy: str = None) -> str:
    """Fetch the list of workspaces owned by the current user. Returns workspace name, description and visibility."""
    oid = get_clean_object_id()
    if not oid:
        return "You must be logged in to access personal workspaces."
    db = await get_db()
    try:
        cursor = db.workspaces.find({"$or": [{"owner": oid}, {"members.user": oid}]}, {"name": 1, "description": 1, "visibility": 1})
        workspaces = await cursor.to_list(length=10)
        if not workspaces:
            return "You have no workspaces."
        res = [f"- Workspace '{w.get('name')}': {w.get('description', 'No description')} (Visibility: {w.get('visibility')})" for w in workspaces]
        return "\n".join(res)
    except Exception as e:
        return f"Error fetching workspaces: {e}"

@tool
async def get_user_alerts(dummy: str = None) -> str:
    """Fetch the list of keyword alerts the current user has set up for their workspaces."""
    oid = get_clean_object_id()
    if not oid:
        return "You must be logged in to access alerts."
    db = await get_db()
    try:
        cursor = db.workspacealerts.find({"createdBy": oid}, {"keyword": 1, "type": 1, "notifyEnabled": 1})
        alerts = await cursor.to_list(length=10)
        if not alerts:
            return "You have no active alerts."
        res = [f"- Alert for keyword '{a.get('keyword')}' (Type: {a.get('type')}, Enabled: {a.get('notifyEnabled')})" for a in alerts]
        return "\n".join(res)
    except Exception as e:
        return f"Error fetching alerts: {e}"

@tool
async def get_user_notes(dummy: str = None) -> str:
    """Fetch the personal research notes created by the current user."""
    oid = get_clean_object_id()
    if not oid:
        return "You must be logged in to access notes."
    db = await get_db()
    try:
        cursor = db.workspacenotes.find({"createdBy": oid}, {"title": 1, "content": 1})
        notes = await cursor.to_list(length=10)
        if not notes:
            return "You have no notes."
        res = [f"- Note '{n.get('title', 'Untitled')}': {n.get('content')}" for n in notes]
        return "\n".join(res)
    except Exception as e:
        return f"Error fetching notes: {e}"

@tool
async def get_user_bookmarks(dummy: str = None) -> str:
    """Fetch the list of bookmarked papers (bookmarks) saved by the current user."""
    oid = get_clean_object_id()
    if not oid:
        return "You must be logged in to access bookmarks."
    db = await get_db()
    try:
        user = await db.users.find_one({"_id": oid})
        if not user or not user.get("bookmarks"):
            return "You have no bookmarks."
        
        paper_ids = user.get("bookmarks")
        cursor = db.papers.find({"_id": {"$in": paper_ids}}, {"title": 1, "doi": 1})
        papers = await cursor.to_list(length=10)
        
        res = [f"- Bookmark '{p.get('title')}': (DOI: {p.get('doi', 'N/A')})" for p in papers]
        return "\n".join(res)
    except Exception as e:
        return f"Error fetching bookmarks: {e}"

tools = [search_database_papers, search_openalex, search_semantic_scholar, search_crossref, get_user_workspaces, get_user_alerts, get_user_notes, get_user_bookmarks]

prompt = PromptTemplate.from_template("""You are an expert academic AI assistant for the "Scientific Journal Publication Trend Tracking System".
This website helps users track scientific publication trends, manage personal Research Workspaces, save papers, create personal notes, and set up keyword alerts (Mobile/Email notifications).
Our system database stores papers curated from OpenAlex, Semantic Scholar, Crossref, and user imports.

You have access to the following tools:

{tools}

If the user asks about the website's features, you can answer directly based on this system description.
If the user asks about their own data (workspaces, alerts, notes, bookmarks), you MUST use the respective tools (`get_user_workspaces`, `get_user_alerts`, `get_user_notes`, `get_user_bookmarks`). You DO NOT need to pass any arguments to these tools.

When answering about academic papers, you MUST ALWAYS provide a highly structured and readable format, including the Title, Authors, Publication Date, Summary, and a direct URL link to the paper.
Always cite your sources in the text using bracket numbers like [1], [2] when mentioning facts from papers.

To use a tool, you MUST use the following format:

Question: the input question you must answer
Thought: you should always think about what to do
Action: the action to take, should be one of [{tool_names}]
Action Input: the input to the action (if no input is needed, write 'None')
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question

If you do not need to use a tool, or you already have the information (e.g., from an image or PDF description provided in the prompt), you MUST still follow the format by starting with a Thought and then the Final Answer:

Thought: I already have the necessary information from the input.
Final Answer: [your detailed answer here]

CRITICAL: NEVER output plain text without "Thought:" and "Final Answer:" prefixes, otherwise the system will crash.

Begin!

Question: {input}
Thought: {agent_scratchpad}""")

# Create Agent using ReAct to avoid strict Gemini tool calling schema errors
agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True, handle_parsing_errors=True)

async def ask_assistant(question: str, user_id: str = None, files: list = None, chat_history: list = None) -> dict:
    """Process the user's question using the RAG Agent, incorporating file content and chat history if present."""
    token = current_user_id.set(user_id)
    try:
        enriched_question = ""
        
        if chat_history:
            history_text = "\n".join([f"{'User' if h['role'] == 'user' else 'AI'}: {h['content']}" for h in chat_history])
            enriched_question += f"--- Chat History ---\n{history_text}\n\n"
            
        enriched_question += f"--- Current Question ---\n{question}"
        if files:
            file_texts = []
            for f in files:
                mime_type = f.get('mime_type', '')
                b64 = f.get('base64_data', '')
                filename = f.get('filename', 'Unknown File')
                
                if not b64:
                    continue
                
                try:
                    file_data = base64.b64decode(b64.split(",")[-1] if "," in b64 else b64)
                    
                    if "pdf" in mime_type.lower():
                        pdf_file = io.BytesIO(file_data)
                        pdf_reader = PdfReader(pdf_file)
                        text = f"--- Content of PDF '{filename}' ---\n"
                        for i, page in enumerate(pdf_reader.pages):
                            if i > 5: # Limit to first 6 pages to save tokens
                                text += "\n[... remaining pages truncated ...]"
                                break
                            text += page.extract_text() + "\n"
                        file_texts.append(text)
                        
                    elif "image" in mime_type.lower():
                        # Use Gemini directly to describe the image
                        try:
                            import google.generativeai as genai
                            from PIL import Image
                            
                            genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
                            img = Image.open(io.BytesIO(file_data))
                            vision_model = genai.GenerativeModel('gemini-3.1-flash-lite')
                            response = vision_model.generate_content(["Describe this image in detail and extract any relevant text or data.", img])
                            
                            text = f"--- Description of Uploaded Image '{filename}' ---\n"
                            text += response.text
                            file_texts.append(text)
                        except Exception as img_err:
                            file_texts.append(f"--- Failed to process image '{filename}' ---: {str(img_err)}")
                            
                except Exception as file_err:
                    file_texts.append(f"--- Failed to process file '{filename}' ---: {str(file_err)}")
                    
            if file_texts:
                enriched_question += "\n\n" + "\n\n".join(file_texts)

        response = await agent_executor.ainvoke({
            "input": enriched_question, 
            "user_id": user_id or "Not logged in"
        })
        return {
            "answer": response.get("output", "No response generated."),
            "sources": [] # The LLM will embed citations in the answer text directly
        }
    except Exception as e:
        import traceback
        err_msg = traceback.format_exc()
        print(f"Agent error: {err_msg}")
        return {
            "answer": f"Sorry, an error occurred while processing your request. Error details: {str(e)}",
            "sources": []
        }
