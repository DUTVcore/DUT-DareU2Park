# D.U.T: Dare U To Park (Đại Chiến Nhà Xe Bách Khoa Đà Nẵng)

Trò chơi 2D góc nhìn từ trên xuống (top-down) mô phỏng việc tìm chỗ đỗ xe máy tại Trường Đại học Bách khoa – Đại học Đà Nẵng (cơ sở 54 Nguyễn Lương Bằng và 60 Ngô Sĩ Liên). Người chơi phải quẹt thẻ sinh viên qua cổng, né chướng ngại vật, gập gương luồn qua các khe hẹp và đỗ xe đúng quy định trước 07:00:00 AM.

## Cơ chế Gameplay

**Phương tiện:**

* **Wave Alpha 110:** Nhỏ gọn, góc đánh lái linh hoạt trong không gian hẹp (biển số 43-K1).
* **Exciter 150:** Gia tốc lớn, phù hợp để rút ngắn thời gian khi sát giờ điểm danh (biển số 92-F1).
* **Vision Smartkey:** Độ bền cao, giảm lệch tay lái khi va phải ổ gà (biển số 75-G1).

**Cơ chế gương:**

* **Gập gương:** Thu hẹp chiều ngang xe để lách qua khe 15cm giữa cột sắt và xe khác mà không bị trừ máu, nhưng bị giới hạn tốc độ.
* **Mở gương:** Cho phép xe đạt tốc độ tối đa và hiển thị vạch hỗ trợ căn chỉnh khi lùi chuồng.

**Màn chơi:**

1. **Khu E:** Quẹt thẻ tại cổng phụ 60 Ngô Sĩ Liên và né ổ gà trên sân trường.
2. **Khu B:** Di chuyển dưới mái tôn che khuất tầm nhìn và lách qua các dãy xe đỗ sát nhau giờ cao điểm.
3. **Khu C:** Đường trơn trượt mùa mưa kèm các hố sâu ẩn dưới vũng nước đục trước Hội trường F.
4. **Khu A:** Tránh ô tô giảng viên tại khu Smart Building và đỗ xe theo quy định lùi chuồng quay đầu ra ngoài.
5. **Màn cuối:** Tổng hợp mọi thử thách vào khung giờ 06:58:20 AM mùa thi cuối kỳ khi các dãy ngoài đã kín chỗ.

**Tính điểm:**

* Xếp hạng theo thang điểm tín chỉ A, B, C hoặc F (quá giờ, phải chơi lại).
* Tự động lưu tiến độ mở khóa màn chơi và kỷ lục cá nhân.

## Điều khiển

| Phím | Hành động |
| --- | --- |
| W, Mũi tên lên | Tăng tốc |
| S, Mũi tên xuống | Phanh hoặc lùi |
| A, D, Trái, Phải | Đánh lái |
| E, Shift | Gập hoặc mở gương |
| F, H | Bóp còi |
| Space | Gạt chân chống |
| R | Chơi lại màn |
| Esc, P | Tạm dừng |
| M | Bật hoặc tắt tiếng |

## Công nghệ và Khởi chạy

* **Engine:** Godot Engine 4.7 (GDScript, 2D)
* **Khởi chạy:** Mở thư mục DareU2Park trong Godot Engine, chọn Main Scene tại đường dẫn res://scenes/ui/MainMenu.tscn và nhấn F5.

**Điểm thiếu sót:**

* **Vênh phiên bản:** Bản gốc ghi Godot 4.7 ở trên nhưng dưới lại ghi 4.x; bạn cần chốt đúng phiên bản tối thiểu vì mở project 4.7 trên bản thấp hơn dễ gây lỗi hỏng scene.
* **Thiếu bản build:** Tài liệu chỉ hướng dẫn chạy mã nguồn cho lập trình viên, hoàn toàn thiếu thông tin tải file thực thi cho người chỉ muốn tải về chơi thử.
* **Diễn đạt ngược:** Bản gốc ghi mở gương để chạy tốc độ tối đa dễ gây hiểu nhầm mở gương là nút tăng tốc; thực tế trạng thái mặc định đã mở gương và việc gập gương mới làm giảm tốc độ.
