# Tài liệu Giải thích Chức năng Quản trị (Admin)
Hệ thống theo dõi xu hướng bài báo khoa học (Scientific Journal Trend Tracker)

Tài liệu này giải thích chi tiết các chức năng dành cho Quản trị viên (Admin) trong việc thiết lập nguồn cấp dữ liệu, theo dõi tiến trình tự động và phân tích xu hướng.

## 1. Chức năng Thêm Nguồn API (Add API Source)

### Ý nghĩa các trường thông tin (Fields)
* **Name (e.g. CrossRef)**: Tên gọi của nguồn dữ liệu API bạn muốn thêm. Dùng để dễ dàng nhận diện và quản lý (ví dụ: "Semantic Scholar", "IEEE").
* **Base URL**: Địa chỉ gốc của API. Đây là đường dẫn mà Backend của hệ thống sẽ dùng để gửi các yêu cầu (HTTP requests) tới máy chủ chứa dữ liệu nhằm tải các bài báo về.
* **Field Scope (e.g. Computer Science...)**: Lĩnh vực chuyên môn của nguồn API này. Việc giới hạn lĩnh vực (như Khoa học máy tính, Y học...) giúp hệ thống biết nguồn này sẽ cung cấp các bài báo về chủ đề gì, từ đó phân loại dữ liệu chính xác hơn.
* **Sync Frequency (Tần suất đồng bộ)**: Thường tính bằng giờ (ví dụ: 24). Tham số này quy định cứ sau bao lâu thì hệ thống sẽ tự động gọi sang API này một lần để cập nhật các bài báo mới nhất.
* **Trend Threshold (Ngưỡng xu hướng)**: (Ví dụ: 5). Tùy vào logic Backend, đây có thể là ngưỡng tính bằng số lượng (từ khóa phải tăng 5% mới gọi là xu hướng) hoặc tính bằng ngày (phân tích xu hướng trong 5 ngày qua). Tham số này giúp thuật toán quyết định xem một chủ đề có đang "hot" hay không.
* **Min Paper Count (Số lượng bài báo tối thiểu)**: (Ví dụ: 10). Đây là bộ lọc nhiễu (noise filter). Nếu một từ khóa hoặc một chủ đề chỉ xuất hiện trong dưới 10 bài báo từ nguồn này, hệ thống sẽ bỏ qua nó. Điều này đảm bảo các xu hướng được báo cáo là thực sự có độ tin cậy và được nhiều người nghiên cứu.
* **Active status (Trạng thái hoạt động)**: Công tắc bật/tắt (Toggle). Khi được bật, hệ thống sẽ tự động đồng bộ dữ liệu. Nếu tắt, hệ thống sẽ tạm ngưng kéo dữ liệu từ nguồn này mà không cần phải xóa hẳn cấu hình.

### Tác dụng và Cách hoạt động (Workflow)
**Tác dụng:** Giúp hệ thống hoạt động chủ động và có thể mở rộng vô hạn. Thay vì phải nhập tay các bài báo hoặc code "cứng" từng nguồn dữ liệu, Admin chỉ cần khai báo trên form. Hệ thống sẽ tự động biến thành một cỗ máy thu thập dữ liệu khổng lồ từ nhiều nguồn khoa học khác nhau.

**Cách hoạt động:**
1. Admin điền thông tin và bấm **Save**.
2. Frontend (Flutter) gửi dữ liệu này xuống Backend (Node.js/TypeScript) để lưu vào Database.
3. Backend có một tiến trình chạy ngầm (cron job hoặc task scheduler). Tiến trình này sẽ quét các API Source có `Active status = true`.
4. Cứ mỗi chu kỳ (dựa theo Sync Frequency), Backend tự động gọi tới Base URL, lấy các bài báo thuộc lĩnh vực Field Scope về.
5. Hệ thống lọc bỏ các chủ đề có số bài báo < Min Paper Count, sau đó đưa qua thuật toán tính toán cùng với Trend Threshold để vẽ ra biểu đồ xu hướng (Trend) đưa lên cho người dùng ứng dụng xem.

---

## 2. Nhật ký Đồng bộ (Sync Execution Logs)

Sau khi thiết lập hệ thống tự động kéo dữ liệu bài báo (ví dụ cứ 24h kéo 1 lần) ở chức năng "Add API Source", màn hình **Sync Execution Logs** chính là nơi để Admin theo dõi xem quá trình kéo dữ liệu đó diễn ra như thế nào.

### Mục đích (Tác dụng)
Hệ thống lấy dữ liệu chạy ngầm (background jobs) nên Admin không thể nhìn thấy trực tiếp. Màn hình Logs này sinh ra để làm "bảng đồng hồ giám sát". Nhìn vào đây, Admin sẽ biết:
* Hệ thống có đang tự động lấy bài báo đúng lịch hay không?
* Nguồn API bên thứ 3 (ví dụ Semantic Scholar) có bị lỗi/sập server khiến việc kéo dữ liệu thất bại không?
* Mỗi lần kéo về thu hoạch được bao nhiêu bài báo mới, bao nhiêu bài bị trùng lặp?

### Cách đọc thông tin trên màn hình
* **Thanh lọc (Filters: All Logs, Success, Failed, Running)**: Giúp Admin lọc nhanh lịch sử. Nếu có lỗi xảy ra, Admin chỉ cần bấm vào "Failed" để xem các tiến trình bị hỏng và tìm cách khắc phục (như kiểm tra lại mạng, xem API có bị hết lượt request chưa).
* **Card Thông tin (Mỗi khung chữ nhật là kết quả của MỘT lần chạy)**:
  * **Tên nguồn**: Ví dụ: Semantic Scholar (nguồn API đã lấy).
  * **Icon Trạng thái**: Dấu tick màu xanh (✅) nghĩa là lấy dữ liệu thành công. Dấu chấm than màu đỏ (❗) nghĩa là có lỗi xảy ra.
  * **Thời gian**: Thời điểm hệ thống tiến hành kéo dữ liệu (ví dụ: 10:40, 10:27).
  * **Keyword**: Từ khóa mà hệ thống vừa dùng để tìm kiếm (Ví dụ: "Artificial Intelligence").
  * **Các chỉ số thống kê (Metrics)**:
    * `+ +0 (Thêm mới)`: Số lượng bài báo mới hoàn toàn vừa được tải về và lưu thành công vào Database.
    * `⏭ 0 (Bỏ qua/Skip)`: Số lượng bài báo đã được lấy về nhưng bị trùng lặp (đã có trong DB từ trước) nên hệ thống tự động bỏ qua để tránh rác dữ liệu.
    * `↻ 0 (Cập nhật)`: Số lượng bài báo đã tồn tại nhưng có dữ liệu mới (ví dụ: tác giả cập nhật thêm, hoặc có thêm lượt trích dẫn mới) nên được ghi đè lại.
* **Nút "Clear Logs" (Màu đỏ)**: Nếu lịch sử chạy quá dài (qua nhiều tháng), Admin có thể bấm nút này để xóa sạch các dòng nhật ký này cho nhẹ Database.

*(Tóm lại: Nếu màn hình **Add API Source** là nơi bạn "ra lệnh" cho hệ thống, thì màn hình **Sync Execution Logs** là nơi hệ thống "báo cáo kết quả" làm việc lại cho bạn.)*

---

## 3. Phân tích Xu hướng (Trend Analysis)

*(Phần này dựa trên cơ chế phân tích từ dữ liệu đã thu thập)*

### Mục đích
Sau khi dữ liệu thô (các bài báo khoa học) được kéo về và làm sạch qua "Sync Execution", hệ thống cần một quá trình xử lý chuyên sâu để tìm ra **Xu hướng (Trend)**. Quá trình này giúp biến hàng ngàn bài báo rời rạc thành những biểu đồ hoặc chỉ số có ý nghĩa cho người dùng (ví dụ: "Chủ đề nào đang hot lên trong 3 năm qua?").

### Cách thức hoạt động
1. **Lọc Dữ Liệu Chuyên Sâu**:
   Hệ thống sẽ lấy tất cả các chủ đề/từ khóa từ cơ sở dữ liệu. Nó sử dụng thông số `Min Paper Count` (Số lượng bài báo tối thiểu) được thiết lập ở màn hình Add API Source. Nếu một chủ đề không đủ số lượng bài viết, hệ thống sẽ gạt nó ra khỏi phân tích để tập trung vào các xu hướng lớn, tránh bị nhiễu.
2. **Tính Toán Bằng Thuật Toán**:
   Từ khóa vượt qua bộ lọc sẽ được đưa vào tính toán mức độ tăng trưởng (Growth Rate) theo các khoảng thời gian (ví dụ: năm này so với năm trước). Thuật toán áp dụng `Trend Threshold` (Ngưỡng xu hướng). 
   *Ví dụ: Nếu số lượng bài báo về "Quantum Computing" năm nay tăng vượt ngưỡng mức Threshold so với năm ngoái, chủ đề này sẽ được gắn nhãn là "Trending" (đang lên).*
3. **Hiển Thị Kết Quả**:
   Kết quả tính toán cuối cùng sẽ được trực quan hoá thành biểu đồ và danh sách trên ứng dụng cho người dùng cuối (Researchers/Sinh viên) để họ có thể xem xu hướng một cách rõ ràng và dễ hiểu nhất.
