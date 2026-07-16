# Tài Liệu: AI Service

**AI Service** là một microservice cực kỳ tinh gọn viết bằng **Python** và **FastAPI**, cung cấp duy nhất tính năng **Trợ lý ảo AI (Chat RAG)** cho ứng dụng.

## 1. Công nghệ sử dụng
- **Framework**: FastAPI (Uvicorn).
- **LLM/Generative AI**: Google Gemini (`gemini-2.5-flash`), thông qua thư viện `langchain-google-genai`.
- **RAG & Agent**: LangChain (Function/Tool Calling Agent).
- **Database**: Motor (MongoDB Async Driver) để truy vấn trực tiếp vào DB chính (Text Search) nhằm hỗ trợ chatbot.
- **Xử lý File**: `PyPDF2` (đọc PDF) và `Pillow` (đọc hình ảnh).

## 2. Chi tiết module Chat (RAG Agent) Service (`/api/v1/chat/ask`)
- **Trợ lý AI** mạnh mẽ dùng LangChain + Gemini, hoạt động như một công cụ truy xuất và tổng hợp thông tin (Retrieval-Augmented Generation).
- **Tool Calling (Function Calling)**: Agent được cung cấp nhiều "Tools" (hàm Python) để tự động gọi khi người dùng hỏi:
  - **Tìm bài báo**: `search_database_papers` (Tìm bằng Text Search trên local MongoDB), `search_openalex`, `search_semantic_scholar`, `search_crossref` (Lấy dữ liệu từ các API học thuật thế giới).
  - **Lấy ngữ cảnh cá nhân của người dùng**: `get_user_workspaces`, `get_user_alerts`, `get_user_notes`, `get_user_bookmarks`, `get_workspace_papers`. AI sẽ tự động đọc các dữ liệu này và trả lời người dùng.
- **Xử lý File Upload**: Có khả năng phân tích nội dung file đính kèm trực tiếp trong khung chat:
  - **PDF**: Dùng `PyPDF2` trích xuất nội dung 6 trang đầu.
  - **Image**: Đẩy hình ảnh qua model vision của Gemini để miêu tả hình ảnh và OCR trước khi nạp vào bối cảnh trả lời.
- **Lưu ý kỹ thuật**: Service sử dụng một phiên bản patch của `_parse_chat_history` trong `langchain-google-genai` để sửa lỗi `json.loads` bị vỡ khi Gemini gọi 2+ tools đồng thời (parallel tool calls) trên version 1.0.x.

## 3. Cấu hình Môi trường (.env)
- `GEMINI_API_KEY`: API Key để gọi Google Gemini.
- `GEMINI_MODEL`: (Tùy chọn) Khuyến nghị dùng `gemini-2.5-flash` do tính tương thích function calling hiện tại.
- `MONGODB_URI`: Chuỗi kết nối đến MongoDB Atlas (Sử dụng Motor để kết nối async).
