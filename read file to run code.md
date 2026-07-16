# Hướng Dẫn Chạy Dự Án (Run Guide)

Tài liệu này hướng dẫn bạn cách khởi động toàn bộ hệ thống dự án bao gồm cả hệ thống Microservices Backend (Docker) và ứng dụng Flutter Frontend.

---

## 1. Khởi động Backend (Microservices)

Hệ thống Backend hiện tại đã được cấu trúc dưới dạng Microservices và được đóng gói toàn bộ bởi **Docker Compose**. Bạn không cần phải mở từng thư mục và chạy thủ công nữa.

### Các bước chạy Backend:
1. Mở **Terminal**, **Command Prompt** hoặc **PowerShell**.
2. Trỏ đường dẫn vào thư mục chứa code Backend:
   ```bash
   cd D:\prm\PRM393_Projects\Scientific_Journal_Trend_Tracker_Backend
   ```
3. Chạy lệnh khởi động bằng Docker Compose:
   ```bash
   docker-compose up -d
   ```
   > **Lưu ý:** Lệnh này sẽ chạy ngầm các dịch vụ (API Gateway, Auth, Core, Interaction, Admin, MongoDB, Redis) ở chế độ background. 
   > - Nếu bạn vừa thay đổi source code ở các service, hãy chạy `docker-compose up -d --build` để Docker biên dịch lại code mới.
4. (Tùy chọn) Để xem log hoạt động của các service, bạn có thể xem trên ứng dụng **Docker Desktop** hoặc dùng lệnh:
   ```bash
   docker-compose logs -f
   ```
5. Để **dừng** và tắt hệ thống Backend khi không cần sử dụng:
   ```bash
   docker-compose down
   ```

---

## 2. Khởi động Frontend (Flutter App)

Frontend là một ứng dụng Flutter nên cần được chạy thông qua IDE (Visual Studio Code, Android Studio) hoặc Terminal.

### Các bước chạy Frontend:
1. Mở thư mục Frontend bằng Editor yêu thích của bạn:
   `D:\prm\PRM393_Projects\scientific_journal_trend_tracker_frontend_flutter_app`
2. Mở Terminal tích hợp của Editor và lấy các thư viện về (nếu là lần đầu tiên mở):
   ```bash
   flutter pub get
   ```
3. Khởi động môi trường thiết bị ảo (Android Emulator / iOS Simulator) hoặc cắm thiết bị thật vào máy tính của bạn. Bạn cũng có thể chọn nền tảng Chrome/Edge/Windows để build thử nghiệm nhanh.
4. Chạy dự án bằng lệnh:
   ```bash
   flutter run
   ```
   Hoặc đơn giản hơn, nếu dùng **VS Code**:
   - Mở file `lib/main.dart`
   - Nhấn phím **F5** hoặc chọn "Run and Debug" trên thanh Menu.

### 💡 Ghi chú về cấu hình kết nối API:
- Backend mới sử dụng API Gateway đóng vai trò làm cổng giao tiếp chung chạy ở cổng **5000**.
- File cấu hình API (`lib/core/constants/api_constants.dart`) đã được setup sẵn biến `useLocal = true`. Mặc định Frontend sẽ tự hiểu:
  - Nếu bạn chạy Emulator Android: API URL tự động gán là `http://10.0.2.2:5000`.
  - Nếu bạn chạy iOS Simulator hoặc Web: API URL sẽ tự động gán là `http://localhost:5000`.
- Mọi kết nối REST API hay WebSockets (để chat / gửi thông báo realtime) đều đi qua API Gateway cổng 5000 này. Bạn không cần tinh chỉnh gì thêm.
