# 🔬 Scientific Journal Trend Tracker

Dự án **Scientific Journal Trend Tracker** là một nền tảng nghiên cứu và phân tích dữ liệu khoa học toàn diện, được thiết kế để giúp các nhà nghiên cứu, giảng viên và sinh viên dễ dàng theo dõi các xu hướng xuất bản, các chủ đề nghiên cứu mới nổi và quản lý dữ liệu bài báo khoa học.

Hệ thống bao gồm hai phần chính:
1. **Backend Microservices**: Xây dựng bằng Node.js, Express, TypeScript, kiến trúc Microservices và được đóng gói toàn bộ bởi Docker.
2. **Frontend App**: Ứng dụng di động đa nền tảng viết bằng Flutter với giao diện trực quan và tối ưu trải nghiệm người dùng.

---

## 📁 Cấu Trúc Dự Án

*   [`Scientific_Journal_Trend_Tracker_Backend/`](./Scientific_Journal_Trend_Tracker_Backend): Chứa toàn bộ mã nguồn backend, gồm các microservices độc lập (API Gateway, Auth, Core, Interaction, Admin) và cấu hình Docker.
*   [`scientific_journal_trend_tracker_frontend_flutter_app/`](./scientific_journal_trend_tracker_frontend_flutter_app): Chứa mã nguồn ứng dụng di động Flutter.

---

## ✨ Các Tính Năng Nổi Bật

### 1. Quản lý Bài báo & Tìm kiếm thông minh
*   Tìm kiếm nội bộ nhanh chóng và tìm kiếm nâng cao trực tiếp từ thư viện quốc tế qua API tích hợp với **Semantic Scholar** và **CrossRef**.
*   Quản lý thông tin bài báo chi tiết (Tiêu đề, Tóm tắt, DOI, Tạp chí, Tác giả...).

### 2. Không gian làm việc cộng tác (Real-time Workspaces)
*   Tạo phòng làm việc nhóm, ghim bài báo và thảo luận trực tiếp thời gian thực (Real-time Chat) thông qua kết nối WebSockets.

### 3. Phân tích Xu hướng (Trend Analysis)
*   Thống kê số lượng bài báo xuất bản qua các năm và theo dõi tốc độ tăng trưởng của từng từ khóa công nghệ/khoa học.
*   Hiển thị biểu đồ xu hướng trực quan giúp nhận diện các chủ đề nghiên cứu đang thịnh hành (Trending Keywords).

### 4. Thu thập Dữ liệu Tự động (Automated Sync)
*   Hệ thống có các tiến trình chạy ngầm định kỳ cào dữ liệu bài báo khoa học từ các nguồn API, tự động lọc nhiễu và phân tích. 
*   Admin có thể dễ dàng thêm các nguồn cung cấp API mới và theo dõi chi tiết lịch sử đồng bộ (Sync Logs).

### 5. Theo dõi & Cá nhân hóa
*   Lưu các bài viết quan trọng vào mục Bookmark.
*   Bấm "Theo dõi" (Follow) các tác giả, từ khóa hoặc tạp chí để nhận các thông báo mới nhất.

---

## 🛠️ Hướng Dẫn Khởi Chạy Nhanh

Hệ thống Backend đã được cấu trúc lại hoàn toàn dưới dạng Microservices và đóng gói bằng **Docker Compose**. Bạn không cần khởi động từng service thủ công nữa.

### 1. Khởi động Backend (Docker)

1. Mở Terminal và trỏ đường dẫn vào thư mục chứa code Backend:
   ```bash
   cd Scientific_Journal_Trend_Tracker_Backend
   ```
2. Chạy lệnh khởi động bằng Docker Compose:
   ```bash
   docker-compose up -d
   ```
   > **Lưu ý:** Lệnh này sẽ chạy ngầm các dịch vụ (API Gateway, Auth, Core, Interaction, Admin, Database) ở chế độ background. Nếu bạn có chỉnh sửa source code ở các service, hãy chạy `docker-compose up -d --build` để build lại.
3. Xem log hoạt động của các service (Tuỳ chọn):
   ```bash
   docker-compose logs -f
   ```
4. Để dừng toàn bộ hệ thống Backend:
   ```bash
   docker-compose down
   ```

### 2. Khởi động Frontend (Flutter App)

1. Di chuyển vào thư mục Frontend:
   ```bash
   cd scientific_journal_trend_tracker_frontend_flutter_app
   ```
2. Cài đặt các thư viện:
   ```bash
   flutter pub get
   ```
3. Khởi chạy ứng dụng:
   ```bash
   flutter run
   ```
   > **Lưu ý về API:** API Gateway của Backend chạy ở cổng `5000`. Cấu hình trong `lib/core/constants/api_constants.dart` đã tự động xử lý địa chỉ: dùng `http://10.0.2.2:5000` cho Android Emulator và `http://localhost:5000` cho iOS/Web. Bạn không cần tinh chỉnh thêm.

---

## 📘 Bảng Phân Quyền Vai Trò (User Roles Matrix)

Hệ thống quản lý chặt chẽ chức năng dựa trên phân quyền vai trò:

| Chức năng | Student (Sinh viên) | Researcher (Nhà nghiên cứu) | Admin (Quản trị viên) |
| :--- | :---: | :---: | :---: |
| Xem Dashboard, Biểu đồ xu hướng | ✅ Có | ✅ Có | ✅ Có |
| Tìm kiếm bài báo & Theo dõi từ khóa | ✅ Có | ✅ Có | ✅ Có |
| Tham gia/Tạo Workspace & Nhắn tin Chat | ✅ Có | ✅ Có | ✅ Có |
| Quản lý Bookmark (Lưu bài viết) | ✅ Có | ✅ Có | ✅ Có |
| Tạo mới/Cập nhật Từ khóa, Tạp chí, Tác giả | ❌ Không | ✅ Có | ✅ Có |
| Quản lý Người dùng hệ thống | ❌ Không | ❌ Không | ✅ Có |
| Cấu hình nguồn API cào dữ liệu (Api Source) | ❌ Không | ❌ Không | ✅ Có |
| Xem và Xóa lịch sử đồng bộ (Sync Logs) | ❌ Không | ❌ Không | ✅ Có |
| Kích hoạt đồng bộ thủ công (Sync Now) | ❌ Không | ❌ Không | ✅ Có |
| Xóa các thực thể (Bài báo, Tác giả, Từ khóa) | ❌ Không | ❌ Không | ✅ Có |
