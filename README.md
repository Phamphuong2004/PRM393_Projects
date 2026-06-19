# Hệ Thống Theo Dõi Xu Hướng Tạp Chí Khoa Học (Scientific Journal Trend Tracker)

Dự án **Scientific Journal Trend Tracker** là một nền tảng nghiên cứu và phân tích dữ liệu khoa học toàn diện, được thiết kế để giúp các nhà nghiên cứu, giảng viên và sinh viên dễ dàng theo dõi các xu hướng xuất bản, các chủ đề nghiên cứu mới nổi và quản lý dữ liệu bài báo khoa học.

Hệ thống bao gồm hai phần chính:
1.  **Backend API**: Xây dựng bằng **Node.js, Express, TypeScript và MongoDB (Atlas)**.
2.  **Frontend App**: Ứng dụng đa nền tảng viết bằng **Flutter (Dart)** với giao diện cao cấp, trực quan và tối ưu trải nghiệm người dùng.

---

## 📁 Cấu Trúc Dự Án

*   [`Scientific_Journal_Trend_Tracker_Backend/`](file:///e:/PRM393_Projects/PRM393_Projects/Scientific_Journal_Trend_Tracker_Backend): Chứa toàn bộ mã nguồn phía máy chủ, cấu hình database, API endpoints và các tác vụ đồng bộ hóa tự động từ API quốc tế.
*   [`scientific_journal_trend_tracker_frontend_flutter_app/`](file:///e:/PRM393_Projects/PRM393_Projects/scientific_journal_trend_tracker_frontend_flutter_app): Ứng dụng di động & desktop (Flutter), quản lý trạng thái bằng `Provider`, định tuyến bằng `GoRouter` và biểu đồ trực quan hóa dữ liệu bằng `fl_chart`.

---

## ✨ Các Tính Năng Nổi Bật

### 🔑 1. Quản lý Người dùng & Xác thực (Auth)
*   Đăng ký, đăng nhập bảo mật bằng cơ chế mã hóa mật khẩu `bcryptjs` và xác thực phiên qua `JWT Token`.
*   Phân quyền người dùng chặt chẽ theo vai trò (Role-based access control): **Admin (Quản trị viên)**, **Researcher (Nhà nghiên cứu)**, và **Student (Học viên/Sinh viên)**.

### 📄 2. Quản lý Bài báo khoa học & Tìm kiếm thông minh
*   Quản lý thông tin bài báo (Tiêu đề, Tóm tắt, DOI, Tạp chí, Tác giả, Năm xuất bản, Số lượt trích dẫn).
*   Tìm kiếm nội bộ nhanh chóng và tìm kiếm nâng cao trực tiếp từ thư viện quốc tế qua API tích hợp với **Semantic Scholar**.

### 📈 3. Phân tích Xu hướng & Trực quan hóa dữ liệu
*   Thống kê số lượng bài báo xuất bản qua các năm và theo dõi tốc độ tăng trưởng của từng từ khóa công nghệ/khoa học.
*   Hiển thị biểu đồ xu hướng trực quan giúp nhận diện các chủ đề nghiên cứu đang thịnh hành (Trending Keywords) hoặc mới nổi (Emerging Topics).

### 👥 4. Quản lý Tác giả (Author Management) - *Mới cập nhật*
*   Hệ thống CRUD hoàn chỉnh cho các Tác giả (Họ tên, Đơn vị công tác, mã số định danh quốc tế ORCID iD, Semantic Scholar ID, Operal ID và tổng số bài báo công bố).
*   Giao diện quản lý thẻ tác giả mượt mà, hỗ trợ tìm kiếm phân trang đầy đủ trên ứng dụng Flutter.

### 🔔 5. Theo dõi & Nhận thông báo
*   Người dùng có thể bấm "Theo dõi" các từ khóa hoặc tạp chí khoa học yêu thích.
*   Nhận thông báo tự động (Notifications) ngay khi hệ thống quét và cập nhật các bài báo mới có chứa từ khóa đang được theo dõi.

### 🛠️ 6. Quản trị Hệ thống & Nhật ký Đồng bộ (Sync Logs) - *Mới cập nhật*
*   **API Sources**: Quản lý cấu hình các nguồn thu thập dữ liệu tự động bên ngoài.
*   **Sync Logs**: Trang quản lý dành riêng cho Admin để theo dõi lịch sử nạp dữ liệu tự động/thủ công (quét được bao nhiêu bài báo mới, bài báo bị bỏ qua do trùng lặp, bài báo cập nhật thông tin và báo lỗi chi tiết nếu quá trình đồng bộ thất bại).
*   **Manual Trigger**: Admin có thể kích hoạt tiến trình đồng bộ dữ liệu ngầm bất cứ lúc nào từ giao diện.

---

## 🛠️ Hướng Dẫn Khởi Chạy Nhanh

### 1. Khởi chạy Backend
1.  Di chuyển vào thư mục backend:
    ```bash
    cd Scientific_Journal_Trend_Tracker_Backend
    ```
2.  Cài đặt các gói thư viện:
    ```bash
    npm install
    ```
3.  Sao chép file cấu hình môi trường và chỉnh sửa các tham số (`MONGODB_URI`, `JWT_SECRET`, `PORT`):
    ```bash
    cp .env.example .env
    ```
4.  Chạy server ở chế độ phát triển:
    ```bash
    npm run dev
    ```
    *API sẽ chạy tại địa chỉ mặc định: `http://localhost:5000`*

### 2. Khởi chạy Frontend Flutter
1.  Di chuyển vào thư mục frontend:
    ```bash
    cd scientific_journal_trend_tracker_frontend_flutter_app
    ```
2.  Cấu hình lại địa chỉ kết nối API trong file `lib/core/constants/api_constants.dart` (khai báo `baseUrl` trỏ về IP máy chủ của bạn).
3.  Tải các thư viện Flutter:
    ```bash
    flutter pub get
    ```
4. Khởi chạy ứng dụng:
    ```bash
    flutter run
    ```

---

## 📘 Hướng Dẫn Sử Dụng Chi Tiết & Phân Quyền

### 1. Bảng Phân Quyền Vai Trò (User Roles Matrix)

Hệ thống quản lý chặt chẽ chức năng dựa trên phân quyền vai trò của người dùng đăng nhập:

| Chức năng | Student (Sinh viên) | Researcher (Nhà nghiên cứu) | Admin (Quản trị viên) |
| :--- | :---: | :---: | :---: |
| Xem Dashboard, Biểu đồ xu hướng | ✅ Có | ✅ Có | ✅ Có |
| Tìm kiếm bài báo (Nội bộ & Quốc tế) | ✅ Có | ✅ Có | ✅ Có |
| Theo dõi (Follow) từ khóa/tạp chí | ✅ Có | ✅ Có | ✅ Có |
| Quản lý Bookmark (Lưu bài viết) | ✅ Có | ✅ Có | ✅ Có |
| Nhận thông báo tự động | ✅ Có | ✅ Có | ✅ Có |
| Tạo mới/Cập nhật Từ khóa, Tạp chí, Chủ đề | ❌ Không | ✅ Có | ✅ Có |
| Tạo mới/Cập nhật Tác giả (Author CRUD) | ❌ Không | ✅ Có | ✅ Có |
| Tạo đợt chạy phân tích (Analysis Run) | ❌ Không | ✅ Có | ✅ Có |
| Quản lý Người dùng (Mở/Khóa, Đổi vai trò) | ❌ Không | ❌ Không | ✅ Có |
| Cấu hình nguồn API cào dữ liệu (ApiSource) | ❌ Không | ❌ Không | ✅ Có |
| Xem và Xóa lịch sử đồng bộ (Sync Logs) | ❌ Không | ❌ Không | ✅ Có |
| Kích hoạt đồng bộ thủ công (Sync Now) | ❌ Không | ❌ Không | ✅ Có |
| Xóa các thực thể (Bài báo, Tác giả, Từ khóa) | ❌ Không | ❌ Không | ✅ Có |

---

### 2. Hướng dẫn thao tác các tính năng chính

#### 📊 A. Xem biểu đồ xu hướng (Dashboard & Trending)
1. Sau khi đăng nhập, hệ thống hiển thị **Trang Chủ (Dashboard)**.
2. Tại đây, bạn có thể xem các thông số tổng quan (Số bài báo, số từ khóa, số tạp chí đang theo dõi).
3. Biểu đồ đường (`fl_chart`) sẽ hiển thị xu hướng tăng trưởng số lượng bài viết của các từ khóa nổi bật theo thời gian.
4. Truy cập menu **Trending** để xem danh sách các từ khóa đang thu hút nhiều sự quan tâm nhất trong cộng đồng học thuật cùng điểm số xu hướng (Trend Score) của chúng.

#### 🔍 B. Tìm kiếm và Thu thập bài báo khoa học (Paper Harvesting)
1. Vào mục **Search Papers** để tìm kiếm bài báo bằng tên hoặc tóm tắt.
2. **Tìm kiếm nội bộ**: Kết quả hiển thị các bài viết đã có sẵn trong cơ sở dữ liệu MongoDB của hệ thống. Bạn có thể bấm Thêm Bookmark để lưu lại.
3. **Thu thập dữ liệu ngoài (Harvesting)**: Nếu không tìm thấy hoặc muốn tìm thêm tài liệu mới nhất từ thư viện quốc tế, hãy nhập từ khóa và bấm **Search External** (Tìm kiếm ngoài).
4. Hệ thống sẽ kết nối trực tiếp với API **Semantic Scholar** để tìm bài viết. Khi bạn click vào kết quả, bài viết đó sẽ được tự động cào và lưu vào database của hệ thống để phân tích xu hướng sau này.

#### 👥 C. Quản lý thông tin tác giả (Authors Screen)
*(Yêu cầu quyền: Researcher hoặc Admin)*
1. Truy cập mục **Authors** trên menu điều hướng.
2. Bạn sẽ thấy danh sách các tác giả khoa học hiển thị dưới dạng card thông tin đẹp mắt, hiển thị số lượng bài báo họ đã công bố.
3. **Thêm tác giả**: Bấm **Add Author** ở góc phải, nhập Họ tên, đơn vị công tác (Affiliation), mã số ORCID iD hoặc Semantic Scholar ID để liên kết dữ liệu tác giả.
4. **Chỉnh sửa**: Click vào biểu tượng cây bút chì trên card tác giả để cập nhật lại thông tin.
5. **Xóa tác giả**: *(Chỉ dành cho Admin)* Click vào biểu tượng thùng rác để xóa thông tin tác giả khỏi hệ thống.

#### 🛠️ D. Đồng bộ dữ liệu & Kiểm tra nhật ký cho Admin (Admin Sync & Logs)
*(Yêu cầu quyền: Admin)*
1. **Kích hoạt đồng bộ**: Vào mục **System Settings**, bạn sẽ thấy danh sách các nguồn cào dữ liệu (Api Sources). Bấm nút **Sync Now** (Đồng bộ ngay) để kích hoạt tiến trình cào bài viết ngầm trong background từ các nguồn API đã cấu hình.
2. **Kiểm tra nhật ký**: Vào mục **Sync Logs** trên menu quản trị.
3. Danh sách hiển thị lịch sử của các lần chạy đồng bộ bài viết tự động (Cron job) hoặc thủ công. Bạn có thể sử dụng các thẻ lọc **All / Success / Failed / Running** để phân loại nhanh.
4. Click vào một dòng nhật ký để xem thông chi tiết: thời gian chạy, thời gian kết thúc, từ khóa dùng để cào, số lượng bài báo mới được thêm vào, số bài trùng lặp đã bỏ qua, và đặc biệt là chi tiết thông báo lỗi (Error message) nếu lần cào đó bị thất bại.
5. Bấm nút **Clear Logs** ở góc trên để dọn sạch lịch sử nhằm giải phóng bộ nhớ cơ sở dữ liệu khi cần.
