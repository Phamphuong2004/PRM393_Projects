# Kiến Trúc Microservices - Scientific Journal Trend Tracker

Tài liệu này giải thích chi tiết vai trò của từng máy chủ (server/service) trong hệ thống Backend và cách mà các đoạn code logic giao tiếp, hoạt động với nhau.

---

## 1. Danh Sách Các Services và Chức Năng

Hệ thống được chia nhỏ thành 5 dịch vụ (Microservices), mỗi dịch vụ chạy độc lập, có database riêng và chỉ đảm nhận một nhóm nghiệp vụ nhất định.

### 🚪 1. API Gateway (Cổng Giao Tiếp Mạng)
- **Cổng chạy:** 5000
- **Tác dụng:** Là "cửa ngõ" duy nhất của toàn bộ hệ thống. Frontend (App Flutter) sẽ gửi toàn bộ Request tới Gateway. Nó đóng vai trò làm bảo vệ, kiểm soát CORS và phân luồng (Proxy) chuyển tiếp các Request đến đúng Service phụ trách bên trong mạng nội bộ.
- **Logic hoạt động:**
  - File `index.ts` sử dụng thư viện `http-proxy-middleware`.
  - Nếu Frontend gọi `/api/auth/*` -> Gateway tự động ném luồng dữ liệu sang `auth-service`.
  - Hỗ trợ truyền ngược WebSockets (`ws: true`) ở đường dẫn `/socket.io` sang `interaction-service`.

### 🔐 2. Auth Service (Quản Lý Người Dùng & Xác Thực)
- **Tác dụng:** Xử lý đăng ký, đăng nhập, bảo mật (Mã hóa mật khẩu bằng Bcrypt, Sinh token JWT), theo dõi danh sách Bookmarks (bài báo đã lưu) và Follows (theo dõi chủ đề).
- **Cơ sở dữ liệu:** Lưu trữ MongoDB Collection `User`.
- **Logic giao tiếp chéo (API Composition):**
  - Khi lấy danh sách Bookmarks/Follows, Auth Service chỉ lưu `id` của bài báo. Nó dùng file `internalApiClient.ts` để "gọi điện" sang Core Service (endpoint `/api/papers/batch`) để lấy chi tiết cụ thể (Tựa đề, Tác giả, Doi) mang về trả cho Frontend.

### 📚 3. Core Service (Lõi Dữ Liệu Nghiên Cứu)
- **Tác dụng:** Là trái tim của hệ thống, quản lý tất cả các thông tin khoa học (Bài báo, Tạp chí, Từ khoá, Tác giả, Chủ đề, Xu hướng công bố).
- **Cơ sở dữ liệu:** Chứa MongoDB Collection `Paper`, `Journal`, `Keyword`, `Institution`, v.v.
- **Logic giao tiếp chéo (API Composition):**
  - Nếu import một Paper mới và cần tạo tự động Follow cho user, Core Service sẽ gọi sang Auth Service.
  - Cung cấp Batch API `/api/papers/batch` cho các service khác gọi tới để lấy hàng loạt Paper cùng lúc nhằm tối ưu hiệu năng và tránh kẹt mạng.

### 💬 4. Interaction Service (Tương Tác & Thời Gian Thực)
- **Tác dụng:** Xử lý các hoạt động thời gian thực như Nhắn tin (Chat), Quản lý Workspace (Không gian làm việc chung) và Chạy mô hình Phân tích. Đặc biệt, Service này chứa máy chủ WebSockets (`Socket.io`) để đẩy thông báo realtime xuống điện thoại người dùng.
- **Cơ sở dữ liệu:** Lưu trữ Workspace, Chat, Logs, v.v.
- **Logic giao tiếp chéo (API Composition):**
  - Trong `WorkspaceService.ts`, khi lấy 1 Workspace, nó sẽ gọi đồng thời sang **Auth Service** để lấy thông tin thành viên (Avatar, Tên) và gọi sang **Core Service** để lấy thông tin Bài báo ghim trong Workspace đó. Sau đó trộn dữ liệu lại gửi cho Frontend.

### ⚙️ 5. Admin Service (Quản Trị Hệ Thống)
- **Tác dụng:** Nơi cấp quyền admin, xem bảng điều khiển (Dashboard) và quản lý hệ thống phân phối thu thập dữ liệu (Sync Logs).
- **Logic giao tiếp chéo (API Composition):**
  - Trong `AdminController.ts`, để hiển thị báo cáo số liệu Dashboard, Service này dùng `Promise.allSettled` gọi cùng lúc tới Auth Service và Core Service để đếm tổng số User, Paper và Journal đang có trong hệ thống mà không cần chọc trực tiếp vào Database của họ.

---

## 2. Cách Code Logic Hoạt Động Cùng Nhau

Mô hình Microservices có một nguyên tắc vàng: **"Các Service tuyệt đối không được đọc chéo trực tiếp Database của nhau"**. Vậy khi cần dữ liệu của nhau, code của bạn xử lý ra sao?

### A. Phương thức giao tiếp (Internal API Client)
Để các Service kết nối với nhau, chúng ta sử dụng thư mục dùng chung `shared/src/utils/internalApiClient.ts`. 

Quy trình một Request diễn ra như sau:
1. **Frontend** gửi token: `GET /api/workspaces/1` kèm `Authorization: Bearer <user_token>`.
2. **Gateway** nhận và chuyển thẳng xuống **Interaction Service**.
3. **Interaction Service** phát hiện ra `Workspace` này chỉ có chuỗi ID của người dùng (ví dụ `"64abcd..."`).
4. **Interaction Service** dùng hàm `createInternalClient(SERVICES.AUTH, req.headers.authorization)` gửi 1 POST Request nội bộ sang **Auth Service** kèm mảng ID: `{ ids: ["64abcd..."] }`.
5. Trong Request nội bộ này, hệ thống sẽ tự động gán thêm một đoạn pass bí mật là Header `x-internal-secret` dựa trên biến môi trường `INTERNAL_API_SECRET`.
6. **Auth Service** nhận được Request. Middleware `internalAuthMiddleware` kiểm tra chữ ký bí mật `x-internal-secret` hợp lệ -> Cho phép lấy dữ liệu siêu tốc.
7. **Auth Service** trả nguyên mảng Profile Users cho **Interaction Service**.
8. **Interaction Service** ghép Profile vừa nhận được vào `Workspace` và trả xuống cho **Frontend**.

### B. Giải Quyết Vấn Đề Hiệu Năng bằng "Batch API"
Nếu trong Workspace có 50 bài báo, nếu gọi sang Core Service 50 lần sẽ làm ngẽn mạng. Do đó, code đã được tối ưu hóa bằng thiết kế **Batch API** (ví dụ: `/api/papers/batch`). 

Code chỉ gửi **1 Request duy nhất** chứa mảng 50 cái ID sang Core Service. Core Service xử lý gom dữ liệu một lần bằng lệnh MongoDB `$in` và trả về 1 mảng 50 bài báo. Việc này được gọi là giải quyết "N+1 query problem" trong kiến trúc phân tán.

---
*(Tài liệu này được tạo vào ngày 14/07/2026. Mọi thiết kế hạ tầng đều đã được hoàn thiện 100% cho nhu cầu mở rộng Production).*
