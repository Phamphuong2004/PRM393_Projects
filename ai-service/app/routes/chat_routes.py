from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional

from app.services.rag_service import ask_assistant

router = APIRouter()

class ChatFile(BaseModel):
    filename: str
    mime_type: str
    base64_data: str

class ChatMessageDict(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    question: str
    user_id: Optional[str] = None
    files: Optional[List[ChatFile]] = []
    chat_history: Optional[List[ChatMessageDict]] = []
    
class ChatResponse(BaseModel):
    answer: str

@router.post("/ask", response_model=ChatResponse)
async def ai_chat(req: ChatRequest):
    """
    RAG Chatbot using LangChain Agent.
    It queries the local MongoDB first and fallbacks to ArXiv.
    """
    try:
        files_dict = [f.dict() for f in req.files] if req.files else []
        history_dict = [h.dict() for h in req.chat_history] if req.chat_history else []
        result = await ask_assistant(req.question, req.user_id, files_dict, history_dict)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
