# TÀI LIỆU CHI TIẾT: UTILS

## 📁 Thư mục: `lib/utils/`

Hiện thư mục utils có một file chính hỗ trợ kiểm tra cấu trúc database.

---

## 1️⃣ `database_checker.dart`

### 🎯 Mục đích
Cung cấp các hàm tiện ích để kiểm tra cấu trúc bảng `tasks` trên Supabase, dùng trong quá trình phát triển hoặc debug.

### 🔑 Class: `DatabaseChecker`

| Method | Trả về | Mô tả | Khi nào dùng |
|--------|--------|-------|--------------|
| `checkImageUrlColumnExists()` | `Future<bool>` | Query 1 record với cột `image_url`. Nếu thành công → cột tồn tại. | Khi vừa thêm trường mới (image_url) và muốn đảm bảo database đã migrate đúng. |
| `checkTasksTableStructure()` | `Future<void>` | Select 1 record từ `tasks`, in ra danh sách key/runtimetype nếu ở chế độ debug. | Debug cấu trúc bảng, kiểm tra các cột/kiểu dữ liệu sau migration. |
| `testCreateTaskWithImage()` | `Future<bool>` | Tạo task test có `image_url`, insert vào DB → xóa đi. Dùng để đảm bảo database chấp nhận field mới. | Khi phát triển tính năng upload ảnh để chắc chắn backend cho phép. |

### 🧠 Sử dụng thực tế
```dart
final hasImageColumn = await DatabaseChecker.checkImageUrlColumnExists();
if (!hasImageColumn) {
  debugPrint('Cần migration thêm cột image_url');
}
```

- Thích hợp chạy trong development (có log `kDebugMode`).
- Không nên dùng trong production vì đây là công cụ kiểm thử.

---

✅ **Đã chú thích thư mục utils!**
