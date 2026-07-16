# BỘ CÂU HỎI BẢO VỆ CHUYÊN NGÀNH SE - CHỨC NĂNG TREND
*(Tuyệt chiêu: Ngắn gọn - Dễ thuộc - Đánh trúng tâm lý giảng viên)*

---

## 1. Kiến trúc & Hệ thống (Microservices & Docker)

**Q1. Tại sao em lại tách chức năng Trend ra thành một Microservice riêng (`core-service`)? Sao không gom chung vào một Project chạy cho nhẹ?**
- **Trả lời:** Dạ để **chống sập (Isolate Failure)** và **dễ mở rộng (Scale)**. Tính Trend là quá trình lặp qua ngàn bài báo rất nặng CPU. Nếu gom chung, lúc hệ thống tính Trend bị quá tải thì người dùng bên ngoài không thể đăng nhập được. Tách riêng ra giúp nếu `core-service` có sập thì `auth-service` (đăng nhập) vẫn sống khỏe ạ.

**Q2. Trong Docker, cái dòng `restart: unless-stopped` có tác dụng gì?**
- **Trả lời:** Dạ đây là cơ chế **Tự động cứu hộ**. Chẳng hạn code em có lỗi làm crash server hoặc máy chủ bị tắt ngang, thì Docker sẽ tự động "dựng đầu" ứng dụng lên chạy lại ngay lập tức để hệ thống không bị gián đoạn.

**Q3. Em muốn tính Trend kết hợp lượt View nằm ở `interaction-service`, nhưng 2 DB khác nhau thì em lấy Data kiểu gì?**
- **Trả lời:** Dạ đặc thù Microservice là không thể `JOIN` hai bảng của hai database khác nhau được. Do đó, `core-service` bên em sẽ gọi một **API nội bộ** sang `interaction-service` để xin số lượng View, hoặc tương lai nâng cấp sẽ dùng **Message Queue** (như RabbitMQ) ạ.

**Q4. Mật khẩu Database (`MONGODB_URI`) chép thẳng vào file `docker-compose.yml` thì lỡ bị lộ mã nguồn trên Github thì sao?**
- **Trả lời:** Dạ ở dự án thực tế em không lưu mật khẩu cứng (hardcode) vào file đó đâu ạ. Em sẽ dùng file `.env` giấu kín (đã thêm vào `.gitignore`) để chứa mật khẩu, Docker lúc chạy sẽ tự đọc biến môi trường lên ạ.

**Q5. Tại sao phải đẻ thêm cái `api-gateway` đứng trước làm gì cho phức tạp hệ thống?**
- **Trả lời:** Dạ `api-gateway` đóng vai trò làm **Bảo vệ cổng (Security Guard)**. Khách hàng không thể gọi thẳng vào `core-service` được. Gateway sẽ đứng ra chặn Spam (Rate Limit), xác thực Token (đăng nhập) trước, nếu hợp lệ mới cho chui vào trong, giúp các service bên trong an toàn tuyệt đối ạ.

---

## 2. Code Backend & Thuật toán

**Q6. Logic gom nhóm dữ liệu (Group by Year) hoạt động như thế nào? Lỡ năm đó không có bài báo nào thì App có bị văng lỗi không?**
- **Trả lời:** Dạ em tạo một Object/Dictionary rỗng. Sau đó dùng vòng lặp duyệt qua các bài báo, trích xuất thuộc tính "Năm" (Year) ra rồi đếm từ khóa và đẩy vào `Map[Năm][Từ Khóa]`. Code của em có dùng cơ chế chống rỗng (ví dụ: `|| 0`), nên nếu năm đó không có bài báo, nó sẽ tự nhả về giá trị `0` chứ không phải là `undefined`. Nhờ đó App không bị văng màn hình đỏ ạ.

**Q7. Công thức em dùng để xếp loại "Đang Hot" (Trending) là gì? Tự code hay dùng thư viện?**
- **Trả lời:** Dạ em tự code công thức **Growth Rate (Tốc độ tăng trưởng)**: `(Năm nay - Năm ngoái) / Năm ngoái * 100`. Nếu độ tăng trưởng vọt qua mốc **20%** thì hệ thống tự đánh dấu là đang hot. Em tự code thuần bằng vòng lặp để dễ dàng thay đổi công thức sau này ạ.

**Q8. Câu hỏi gài: Lỡ sau này website có 1 triệu bài báo, cách lặp vòng for kéo hết data về Node.js sẽ làm cháy RAM (Out of Memory). Em giải quyết sao?**
- **Trả lời:** Dạ em biết đây là "Nút thắt cổ chai" (Bottleneck). Khắc phục bằng cách em sẽ không kéo hết data về Node.js nữa. Thay vào đó, em dùng **Aggregation Pipeline** của MongoDB (như `$group`, `$sum`). Database sẽ tự đếm cục bộ ở dưới DB rồi chỉ nhả đúng một file JSON kết quả siêu nhỏ lên cho Node.js, như vậy RAM sẽ hoàn toàn an toàn ạ.

**Q9. Tại sao em lại tách phần tính toán logic ra file `TrendAnalyzerService.ts` riêng biệt chứ không nhét chung vào Controller?**
- **Trả lời:** Dạ em áp dụng nguyên lý **Đơn trách nhiệm (Single Responsibility)**. Controller chỉ làm nhiệm vụ nhận Request và trả Response. Còn Service chứa não bộ tính toán (Business Logic). Tách ra như vậy để dễ bảo trì, dễ viết Unit Test cho hàm tính Trend mà không cần gọi API thật ạ.

---

## 3. Frontend (Flutter App) & Database

**Q10. Trong chức năng Trend này, Flutter App của em đóng vai trò gì?**
- **Trả lời:** Dạ Flutter bên em theo chuẩn **Thin Client (Client mỏng)**. Nó hoàn toàn không tính toán logic nặng nào cả. Nó chỉ mở cửa hứng file JSON từ Backend thả xuống, đọc các con số điểm Trend rồi nhét vào thư viện (`fl_chart` hoặc `syncfusion`) để **vẽ biểu đồ trực quan** lên màn hình điện thoại thôi ạ.

**Q11. SQL có hàm `GROUP BY` rất ngon để làm hàm Trend này, cớ sao em lại chọn MongoDB (NoSQL)?**
- **Trả lời:** Dạ vì dữ liệu bài báo khoa học có **cấu trúc cực kỳ linh hoạt (Flexible Schema)**. Có bài 1 tác giả, bài 5 tác giả, số từ khóa cũng dài ngắn khác nhau. Nếu dùng MySQL sẽ phải tạo rất nhiều bảng và `JOIN` chéo nhằng nhịt làm chậm hệ thống. Dùng MongoDB thì cứ ném cục JSON vào là xong. Hơn nữa MongoDB cũng có Aggregation gom nhóm mạnh y hệt SQL ạ.

**Q12. Khi API Trend đang xử lý vòng lặp (mất khoảng 3 giây), thì màn hình Flutter của người dùng bị đơ luôn đúng không? Em xử lý sao?**
- **Trả lời:** Dạ không ạ. Ở Flutter em dùng **FutureBuilder** (hoặc State Management) để gọi API bất đồng bộ. Trong lúc chờ 3 giây đó, màn hình sẽ hiển thị hiệu ứng xoay xoay (CircularProgressIndicator) hoặc Skeleton Loading, khi nào có data về thì nó mới vẽ biểu đồ, mang lại trải nghiệm mượt mà không bị "đóng băng" app ạ.

**Q13. Dữ liệu bài báo lên tới hàng chục nghìn bài, làm sao em tìm kiếm (Query) các bài báo thuộc năm 2023 nhanh được? Quét từ đầu đến cuối DB chắc treo máy luôn?**
- **Trả lời:** Dạ để query nhanh thì em phải đánh **Index (Chỉ mục)** trong MongoDB cho cột `Year` hoặc cột `Keywords`. Có Index rồi thì thay vì DB phải quét từ đầu đến cuối (Full Collection Scan), nó sẽ nhảy thẳng tới đúng các bài báo đó theo cấu trúc cây (B-Tree), truy xuất trong vài mili-giây ạ.

**Q14. Mỗi lần User mở App xem Trend là mỗi lần Server lại phải cắm đầu chạy vòng lặp tính toán lại từ đầu. Việc này có quá ngu ngốc và tốn tài nguyên không?**
- **Trả lời:** Dạ đúng là rất tốn ạ. Nên thực tế em áp dụng **Caching (Lưu đệm)**. Hoặc thiết lập **Cronjob (tác vụ chạy ngầm)** cứ 12h đêm hệ thống tự động gom bài báo tính sẵn điểm Trend rồi lưu chốt vào bảng `PublicationTrend`. Hôm sau User mở App thì chỉ bốc điểm có sẵn ra xem luôn (tốc độ O(1)) chứ không phải ngồi tính lại nữa.

**Q15. Lỡ có 2 Admin cùng lúc bấm cập nhật điểm Trend cho cùng 1 Topic (cùng 1 mili-giây), Database của em có bị đè mất dữ liệu không (Race Condition)?**
- **Trả lời:** Dạ nguy cơ là có ạ. Để né lỗi này, em không lấy điểm cũ ra, cộng thêm rồi `.save()` lại. Em dùng trực tiếp toán tử **`$inc` (increment)** của MongoDB. Đây là *Atomic Operation* (chạy nguyên tử độc lập dưới DB), nó tự động xếp hàng cộng dồn an toàn, đảm bảo điểm vẫn lên đủ 2 lần không bị thất thoát ạ.

---

## 4. Thực Chiến "Chỉ Thẳng Vào Code" (Review Code Tại Chỗ)

*Giảng viên SE rất thích bắt sinh viên mở màn hình IDE (VS Code) lên và yêu cầu: "Em mở code lên, chỉ cho tôi xem đoạn nào em làm chức năng ABC..."*

**Q16. Giảng viên: "Em nói em có chống lỗi Null/Undefined bằng `|| 0`, mở code lên chỉ tôi xem đoạn đó nằm ở đâu?"**
- **Hành động của bạn:** Mở ngay file `TrendAnalyzerService.ts` hoặc `PublicationTrendService.ts`.
- **Trả lời & Chỉ chuột:** "Dạ thưa thầy, nó nằm ở dòng này ạ. Khi em truy xuất vào `trendsMap[year][keyword]`, nếu năm đó chưa có ai tạo key thì kết quả trả về là `undefined`. Nhờ có cái `|| 0` (toán tử logic OR) ở đuôi này, nó sẽ gán điểm bằng 0 trước khi cộng dồn, giúp vòng lặp không bị chết (crash) giữa chừng ạ."

**Q17. Giảng viên: "Đoạn code tính Tốc độ tăng trưởng (Growth Rate) 20% nằm ở file nào, dòng số mấy?"**
- **Hành động của bạn:** Mở file chứa logic phân tích Trend (thường là `TrendAnalyzerService.ts`). Tìm đến đoạn có công thức chia.
- **Trả lời & Chỉ chuột:** "Dạ đoạn công thức nằm ở khối lệnh này ạ. Thầy xem dòng code `(currentCount - previousCount) / previousCount`. Sau đó phía dưới em có một cái lệnh `if (growthRate > 20) { isTrending = true; }`. Tương lai nếu muốn đổi sang 30% em chỉ cần sửa đúng con số 20 ở dòng này thôi ạ."

**Q18. Giảng viên: "Service của em gọi xuống Database (MongoDB) ở chỗ nào? Dùng cái gì để gọi?"**
- **Hành động của bạn:** Mở file Repository hoặc trực tiếp file Service.
- **Trả lời & Chỉ chuột:** "Dạ đây thưa thầy. Em dùng thư viện **Mongoose**. Chỗ dòng lệnh `PublicationModel.find(...)` này chính là lúc backend gửi câu Query chui xuống MongoDB để gom data lên. Chữ `await` đứng trước là để ra lệnh cho Node.js phải đứng chờ lấy xong data thì mới chạy tiếp vòng lặp phía dưới ạ."

**Q19. Giảng viên: "Bên Flutter gọi API ở file nào? Chỗ nào hiển thị hiệu ứng Loading xoay xoay em vừa nói?"**
- **Hành động của bạn:** Mở thư mục code Frontend (Flutter). Tìm file View (Screen) chứa trang Trend.
- **Trả lời & Chỉ chuột:** "Dạ thưa thầy, em gọi API thông qua biến `Future` (hoặc `Bloc/Provider`) ở chỗ này. Còn đoạn `CircularProgressIndicator()` nằm trong khối lệnh `if (snapshot.connectionState == ConnectionState.waiting)` này chính là hiệu ứng xoay xoay chờ Data. Khi Data về đủ, nó sẽ chạy xuống nhánh `else` và return ra cục `BarChart / LineChart` ạ."

---
*💡 **Mẹo khi bảo vệ:** Đừng bao giờ lúng túng bấm tìm kiếm `Ctrl + F` loạn ngầu khi thầy yêu cầu mở code. Tối hôm trước khi bảo vệ, hãy mở sẵn tất cả các file `...Service.ts` quan trọng lên các Tab của VS Code. Thầy hỏi một phát, click thẳng sang cái Tab đó chỉ luôn. Tốc độ mở code nhanh chứng tỏ 100% bạn tự code!*

---

## 5. Kịch Bản "Giải Thích Từng Dòng Code" (Line-by-line Explanation)

*Nếu giảng viên khó tính yêu cầu: "Em giải thích cho tôi vòng lặp for này từng dòng nó chạy như thế nào?", hãy bê nguyên văn kịch bản dưới đây:*

### Kịch bản 1: Giải thích vòng lặp tính Trend ở Backend (Node.js)
*(Mở file `TrendAnalyzerService.ts` lên đoạn vòng lặp và nói)*

- **Dòng `const trendsMap = {};`**: "Dạ dòng này em khởi tạo một Object rỗng để làm cái xô đựng dữ liệu."
- **Dòng `for (const article of articles) { ... }`**: "Dạ đây là vòng lặp duyệt qua toàn bộ bài báo vừa lấy từ Database lên."
- **Dòng `const year = article.publishDate.getFullYear();`**: "Dạ hàm `getFullYear()` này móc lấy cái 'Năm' từ chuỗi ngày tháng của bài báo."
- **Dòng `if (!trendsMap[year]) trendsMap[year] = {};`**: "Dạ dòng này cực kỳ quan trọng. Em check xem cái năm này đã có trong xô chưa, nếu chưa có thì em tạo sẵn một cái khoang trống cho năm đó để tí nữa nhét từ khóa vào, né lỗi undefined."
- **Dòng `for (const keyword of article.keywords) { ... }`**: "Dạ bài báo có nhiều từ khóa, nên em dùng thêm vòng lặp thứ 2 để đi qua từng từ khóa một."
- **Dòng `trendsMap[year][keyword] = (trendsMap[year][keyword] || 0) + 1;`**: "Dạ dòng chốt đây ạ. Nó nhảy vào khoang của năm đó, tìm đúng cái từ khóa đó. Cái `|| 0` nghĩa là nếu từ khóa này xuất hiện lần đầu thì cho nó bằng 0 rồi cộng 1. Nếu đã có rồi thì lấy số cũ cộng thêm 1."

### Kịch bản 2: Giải thích luồng gọi API và vẽ biểu đồ ở Frontend (Flutter)
*(Mở file màn hình Trend UI của Flutter lên và nói)*

- **Dòng `FutureBuilder<TrendData>( ... )`**: "Dạ em bọc nguyên cái màn hình bằng Widget `FutureBuilder`. Thằng này sinh ra để xử lý các tác vụ bất đồng bộ (như gọi API mất vài giây)."
- **Dòng `future: apiService.fetchTrends(),`**: "Dạ đây là chỗ nó bắn request lên API Gateway của Backend. Nó sẽ chạy ngầm không làm đơ UI."
- **Dòng `if (snapshot.connectionState == ConnectionState.waiting)`**: "Dạ trong lúc chờ Backend trả JSON về (khoảng 2-3 giây), nó lọt vào nhánh `if` này."
- **Dòng `return CircularProgressIndicator();`**: "Dạ lệnh này sẽ vẽ ra cái vòng tròn xoay xoay xoay trên màn hình để báo cho User biết là đang tải dữ liệu."
- **Dòng `if (snapshot.hasError)`**: "Dạ lỡ Backend sập hoặc mất mạng, nó sẽ lọt vào đây và em return ra câu thông báo lỗi đỏ chót."
- **Dòng `if (snapshot.hasData)`**: "Dạ đây là khi data đã về an toàn. Em bóc cục `snapshot.data` ra, nhét thẳng vào Widget `LineChart` của thư viện `fl_chart` để nó vẽ ra biểu đồ vút lên vút xuống ạ."

### Kịch bản 3: Các dòng code "bắt buộc phải biết" khác ở Backend
*(Mở file `PublicationTrendController.ts` hoặc `routes` lên)*

- **Dòng `router.get('/trends', trendController.getTrends);`**: "Dạ đây là file Route (Bộ định tuyến). Nó giống như cái bảng chỉ đường, hễ ai gọi API method GET vào đường dẫn `/trends` thì nó sẽ dẫn chui vào hàm `getTrends` của Controller."
- **Dòng `const { limit, keyword } = req.query;`**: "Dạ ở Controller em dùng lệnh này để hứng các tham số người dùng gõ trên URL (ví dụ `?limit=10&keyword=AI`), sau đó em mới ném các tham số này xuống cho tầng Service xử lý."
- **Dòng `try { ... } catch (error) { res.status(500).json(...) }`**: "Dạ em bọc toàn bộ code bằng `try-catch`. Lỡ DB có sập thì nó nhảy xuống `catch` và nhả về mã lỗi 500 (Internal Server Error) cho Frontend, chứ tuyệt đối không để server Node.js bị crash chết ngang ạ."

### Kịch bản 4: Code xử lý Data phía Flutter (Call API & Map Data)
*(Mở file `api_service.dart` hoặc file `trend_model.dart` trong thư mục Flutter)*

- **Dòng `final response = await http.get(Uri.parse('...'));`**: "Dạ dòng này dùng thư viện `http` (hoặc `dio`) để bắn Request lên server. Chữ `await` báo cho App biết là phải đứng chờ lấy xong JSON thì mới làm tiếp."
- **Dòng `if (response.statusCode == 200)`**: "Dạ em check mã HTTP. Trả về đúng 200 (OK) thì em mới xử lý tiếp, nếu nhả về 400 hay 500 thì em quăng lỗi (throw Exception) để báo cho người dùng."
- **Dòng `factory TrendModel.fromJson(Map<String, dynamic> json)`**: "Dạ lúc API trả về nó chỉ là một chuỗi JSON khô khan không có kiểu dữ liệu. Em phải dùng hàm `fromJson` này để ép kiểu nó thành 1 Object (Model) thực thụ trong Dart, giúp code an toàn và có gợi ý (Auto-complete)."
- **Dòng `spots: data.map((e) => FlSpot(e.year, e.count)).toList()`**: "Dạ thư viện biểu đồ `fl_chart` nó không tự hiểu data của em. Em phải dùng lệnh `.map` này để biến từng năm, từng số lượng thành một toạ độ `FlSpot(x, y)`, tương ứng trục X là Năm, trục Y là Điểm, thì nó mới vẽ lên hình được ạ."
