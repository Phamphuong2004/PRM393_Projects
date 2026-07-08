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

# Gemini model name (configurable so we don't hardcode it in multiple places)
# NOTE: Gemini 3.x models (e.g. gemini-3.5-flash) require `thought_signature` on
# replayed function calls, which langchain-google-genai 1.0.x does not support ->
# multi-turn tool calling 400s. Stay on gemini-2.5-flash until the lib is upgraded.
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")

# Initialize Gemini Chat Model
llm = ChatGoogleGenerativeAI(
    model=GEMINI_MODEL,
    temperature=0.3,
    max_output_tokens=4096,
    google_api_key=os.getenv("GEMINI_API_KEY")
)

# --- Patch: parallel tool-call history bug in langchain-google-genai (1.0.x) ---
# The stock _parse_chat_history rebuilds an AIMessage's calls from a single
# concatenated additional_kwargs["function_call"], so when Gemini emits >=2 tool
# calls in one turn the arguments become "{}{}" and json.loads() crashes with
# "Extra data: line 1 column 3 (char 2)". It also names every parallel tool
# response after tool_calls[0]. We rebuild from message.tool_calls (already dicts)
# and match responses by tool_call_id.
import langchain_google_genai.chat_models as _lcg_cm
from langchain_core.messages import (
    SystemMessage as _SystemMessage,
    AIMessage as _AIMessage,
    HumanMessage as _HumanMessage,
    FunctionMessage as _FunctionMessage,
    ToolMessage as _ToolMessage,
)


def _patched_parse_chat_history(input_messages, convert_system_message_to_human=False):
    Content = _lcg_cm.Content
    Part = _lcg_cm.Part
    FunctionCall = _lcg_cm.FunctionCall
    FunctionResponse = _lcg_cm.FunctionResponse
    _convert_to_parts = _lcg_cm._convert_to_parts

    system_instruction = None
    messages = []
    for i, message in enumerate(input_messages):
        if i == 0 and isinstance(message, _SystemMessage):
            system_instruction = Content(parts=_convert_to_parts(message.content))
            continue
        elif isinstance(message, _AIMessage):
            role = "model"
            if message.tool_calls:
                # tool_calls[*]["args"] is already a dict -> no json.loads, no concat bug
                parts = [
                    Part(function_call=FunctionCall({"name": tc["name"], "args": tc["args"]}))
                    for tc in message.tool_calls
                ]
            else:
                raw_function_call = message.additional_kwargs.get("function_call")
                if raw_function_call:
                    parts = [
                        Part(
                            function_call=FunctionCall(
                                {
                                    "name": raw_function_call["name"],
                                    "args": json.loads(raw_function_call["arguments"]),
                                }
                            )
                        )
                    ]
                else:
                    parts = _convert_to_parts(message.content)
        elif isinstance(message, _HumanMessage):
            role = "user"
            parts = _convert_to_parts(message.content)
        elif isinstance(message, _FunctionMessage):
            role = "user"
            try:
                response = json.loads(message.content) if isinstance(message.content, str) else message.content
            except json.JSONDecodeError:
                response = message.content
            parts = [
                Part(
                    function_response=FunctionResponse(
                        name=message.name,
                        response={"output": response} if not isinstance(response, dict) else response,
                    )
                )
            ]
        elif isinstance(message, _ToolMessage):
            role = "user"
            # Resolve the tool name by matching tool_call_id against earlier AI tool_calls
            name = message.name
            call_id = getattr(message, "tool_call_id", None)
            for prev in reversed(input_messages[:i]):
                if isinstance(prev, _AIMessage) and prev.tool_calls:
                    match = next((tc for tc in prev.tool_calls if tc.get("id") == call_id), None)
                    if match:
                        name = match["name"]
                        break
                    if name is None:
                        name = prev.tool_calls[0]["name"]
                        break
            try:
                tool_response = json.loads(message.content) if isinstance(message.content, str) else message.content
            except json.JSONDecodeError:
                tool_response = message.content
            parts = [
                Part(
                    function_response=FunctionResponse(
                        name=name,
                        response={"output": tool_response} if not isinstance(tool_response, dict) else tool_response,
                    )
                )
            ]
        else:
            raise ValueError(f"Unexpected message with type {type(message)} at the position {i}.")

        messages.append(Content(role=role, parts=parts))
    return system_instruction, messages


_lcg_cm._parse_chat_history = _patched_parse_chat_history
# --- end patch ---

@tool
async def search_database_papers(query: str, limit: int = 5) -> str:
    """Search for relevant academic papers in the local MongoDB database.
    Use this first to find papers already in the system.
    Pass `limit` to control how many papers to return (default 5).
    """
    db = await get_db()
    limit = max(1, min(limit, 25))  # clamp to a sane range

    papers = []
    try:
        cursor = db.paper.find(
            {"$text": {"$search": query}},
            {"score": {"$meta": "textScore"}, "title": 1, "abstract": 1, "publicationYear": 1, "doi": 1, "url": 1}
        ).sort([("score", {"$meta": "textScore"})]).limit(limit)
        papers = await cursor.to_list(length=limit)
    except Exception as e:
        print(f"MongoDB text search error (likely missing index): {e}")
        papers = []

    if not papers:
        # Fallback to regex if text index is missing or no results
        try:
            cursor = db.paper.find(
                {"title": {"$regex": query, "$options": "i"}},
                {"title": 1, "abstract": 1, "publicationYear": 1, "doi": 1, "url": 1}
            ).limit(limit)
            papers = await cursor.to_list(length=limit)
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
        cursor = db.paper.find({"_id": {"$in": paper_ids}}, {"title": 1, "doi": 1})
        papers = await cursor.to_list(length=10)
        
        if not papers:
            return f"You have {len(paper_ids)} bookmarks, but their details could not be retrieved from the database."
            
        res = [f"- Bookmark '{p.get('title')}': (DOI: {p.get('doi', 'N/A')})" for p in papers]
        if len(paper_ids) > 10:
            res.append(f"... and {len(paper_ids) - 10} more.")
        return "\n".join(res)
    except Exception as e:
        return f"Error fetching bookmarks: {e}"

@tool
async def get_workspace_papers(workspace_name: str) -> str:
    """Fetch the list of papers saved within a specific workspace. 
    Args:
        workspace_name: The name of the workspace to inspect.
    """
    oid = get_clean_object_id()
    if not oid:
        return "You must be logged in."
    db = await get_db()
    try:
        # Find the workspace by name
        workspace = await db.workspaces.find_one({
            "name": {"$regex": f"^{workspace_name}$", "$options": "i"},
            "$or": [{"owner": oid}, {"members.user": oid}]
        })
        if not workspace:
            return f"Workspace '{workspace_name}' not found or you don't have access to it."
            
        workspace_id = workspace["_id"]
        
        # Get papers linked to this workspace
        cursor = db.workspacepapers.find({"workspace": workspace_id})
        workspace_papers = await cursor.to_list(length=50)
        
        if not workspace_papers:
            return f"Workspace '{workspace_name}' is empty (no papers saved)."
            
        paper_ids = [wp["paper"] for wp in workspace_papers if "paper" in wp]
        if not paper_ids:
             return f"Workspace '{workspace_name}' is empty."
             
        p_cursor = db.paper.find({"_id": {"$in": paper_ids}}, {"title": 1, "doi": 1})
        papers = await p_cursor.to_list(length=50)
        
        res = [f"- Paper '{p.get('title')}': (DOI: {p.get('doi', 'N/A')})" for p in papers]
        return f"Papers in '{workspace_name}':\n" + "\n".join(res)
    except Exception as e:
        return f"Error fetching workspace papers: {e}"

tools = [search_database_papers, search_openalex, search_semantic_scholar, search_crossref, get_user_workspaces, get_user_alerts, get_user_notes, get_user_bookmarks, get_workspace_papers]

SYSTEM_PROMPT = """You are an expert academic AI assistant for the "Scientific Journal Publication Trend Tracking System".
This website helps users track scientific publication trends, manage personal Research Workspaces, save papers, create personal notes, and set up keyword alerts (Mobile/Email notifications).
Our system database stores papers curated from OpenAlex, Semantic Scholar, Crossref, and user imports.

Rules you MUST follow:
- If the user asks about the website's features, answer directly from this description.
- If the user asks about THEIR OWN data (workspaces, alerts, notes, bookmarks, papers in a workspace), you MUST call the matching tool (`get_user_workspaces`, `get_user_alerts`, `get_user_notes`, `get_user_bookmarks`, `get_workspace_papers`) and answer ONLY from its result. NEVER claim the user has no data without calling the tool first.
- When asking for papers in a specific workspace, use `get_workspace_papers` with the workspace name.
- When the user asks for a specific number of papers (e.g. "10 papers"), pass that number as the `limit` argument to the search tool. Do not silently return fewer than requested if more are available.
- When providing summaries for multiple papers, keep each summary EXTREMELY CONCISE (1-2 sentences maximum). Do not translate or output the entire full abstract, otherwise the response will be cut off.
- When answering about academic papers, ALWAYS use a structured, readable format including Title, Authors, Publication Date, Summary, and a direct URL link.
- Cite sources inline using bracket numbers like [1], [2] when stating facts from papers.
- If content from an uploaded image or PDF is already provided in the message, answer from it directly without searching."""

prompt = ChatPromptTemplate.from_messages([
    ("system", SYSTEM_PROMPT),
    ("human", "{input}"),
    MessagesPlaceholder("agent_scratchpad"),
])

# Use Gemini's native function calling (reliable tool invocation + multi-argument
# support) instead of ReAct text parsing, which Gemini frequently violated and
# which could not forward numeric args such as `limit`.
agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True, handle_parsing_errors=True, max_iterations=8)

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
                            vision_model = genai.GenerativeModel(GEMINI_MODEL)
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
        # Citations are embedded directly in the answer text (e.g. [1], [2]).
        return {
            "answer": response.get("output", "No response generated."),
        }
    except Exception as e:
        import traceback
        err_msg = traceback.format_exc()
        print(f"Agent error: {err_msg}")
        return {
            "answer": f"Sorry, an error occurred while processing your request. Error details: {str(e)}",
        }
