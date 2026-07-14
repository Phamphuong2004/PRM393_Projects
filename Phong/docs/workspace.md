# Tài Liệu: Workspace (Không Gian Làm Việc)

Hệ thống Workspace trong **Scientific Journal Trend Tracker** cho phép người dùng tạo các không gian làm việc cá nhân hoặc nhóm để quản lý bài báo, ghi chú và nhận thông báo (alerts) liên quan đến nghiên cứu.

## 1. Các Models Chính
- **Workspace**: Lưu trữ thông tin chung của workspace (tên, mô tả, visibility), người tạo (owner), và danh sách thành viên (kèm vai trò).
- **WorkspacePaper**: Bảng trung gian liên kết giữa Workspace và Paper. Lưu trữ thông tin bài báo được thêm vào workspace, bao gồm thẻ tags, ghi chú (note), nguồn thêm (source), và người thêm.
- **WorkspaceNote**: Ghi chú (note) của người dùng trong một workspace. Có thể liên kết hoặc không liên kết với một bài báo cụ thể.
- **WorkspaceAlert**: Cảnh báo/Theo dõi từ khóa. Khi có bài báo mới được thêm vào workspace khớp với `query`, hệ thống sẽ gửi thông báo cho các thành viên.

## 2. Phân Quyền (RBAC) Trong Workspace
Mỗi thành viên trong workspace được gán một vai trò:
- **Owner**: Người tạo workspace. Có toàn quyền: sửa/xóa workspace, quản lý thành viên (thêm/xóa/đổi vai trò), và mọi quyền của Editor.
- **Editor**: Có thể thêm/xóa bài báo, cập nhật PDF, tạo/sửa/xóa ghi chú, và cấu hình alerts.
- **Viewer**: Chỉ có quyền xem danh sách bài báo, ghi chú, alerts, thành viên, và thông tin chi tiết.

## 3. Các Luồng Xử Lý Chính
### Quản Lý Workspace
- **Tạo mới**: Người dùng tạo workspace mặc định sẽ trở thành `owner`.
- **Thành viên**: `owner` có thể thêm thành viên bằng email. Nếu user có tồn tại trong hệ thống, user đó sẽ được thêm với vai trò được chỉ định.

### Quản Lý Bài Báo Trong Workspace
- **Thêm bài báo**: Có thể thêm từ Local Database (qua `paperId`) hoặc tạo mới trực tiếp từ dữ liệu nguồn ngoài (externalId). Khi tạo mới, API sẽ tự động xử lý trùng lặp (`doi`, `openalexId`, v.v.).
- **Alert Trigger**: Ngay sau khi một bài báo được thêm vào workspace, hệ thống sẽ kiểm tra danh sách `WorkspaceAlert`. Nếu tiêu đề hoặc tóm tắt của bài báo chứa từ khóa (query) của alert, hệ thống sẽ tự động tạo `Notification` gửi đến toàn bộ thành viên trong workspace.
- **Upload PDF**: Người dùng có thể upload file PDF cho một bài báo. File được đẩy lên Cloudinary (nếu đã cấu hình) hoặc lưu cục bộ trong thư mục `uploads/`. URL PDF được lưu trên document `Paper` gốc.

### Quản Lý Ghi Chú & Cảnh Báo
- **Notes**: CRUD ghi chú văn bản thuần túy hoặc markdown liên quan đến nghiên cứu.
- **Alerts**: Người dùng có thể tạo một Alert với `query` nhất định để theo dõi. (Việc quét alert diễn ra real-time khi có bài báo được add thủ công vào workspace, và tiềm năng có thể mở rộng chạy qua cronjob định kỳ).

## 4. API Endpoints
Tất cả endpoints đều bắt đầu với `/api/workspaces` và yêu cầu xác thực (`authMiddleware`).
- `POST /`: Tạo workspace.
- `GET /`: Lấy danh sách workspaces của user đang đăng nhập (phân trang).
- `PUT /:id` | `DELETE /:id`: Sửa/Xóa workspace.
- `GET /:id`: Xem chi tiết workspace (thống kê bài báo, ghi chú, danh sách thành viên).
- `POST /:id/members` | `DELETE /:id/members/:userId`: Quản lý thành viên.
- `POST /:id/papers` | `DELETE /:id/papers/:paperId`: Thêm/Xóa bài báo khỏi workspace.
- `GET /:id/papers`: Lấy danh sách bài báo (hỗ trợ lọc theo `tag`, phân trang).
- `POST /:id/papers/:paperId/pdf` | `DELETE /:id/papers/:paperId/pdf`: Quản lý file PDF.
- `POST /:id/notes`, `GET /:id/notes`, `PUT /:id/notes/:noteId`, `DELETE /:id/notes/:noteId`: Quản lý notes.
- `POST /:id/alerts`, `GET /:id/alerts`, `DELETE /:id/alerts/:alertId`: Quản lý alerts.
