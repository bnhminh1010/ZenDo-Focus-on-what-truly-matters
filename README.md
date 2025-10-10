# ZenDo - Focus on what truly matters

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase">
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
</div>

## 📱 Giới thiệu

**ZenDo** là ứng dụng quản lý công việc và tập trung được xây dựng với Flutter, giúp người dùng tối ưu hóa năng suất và tập trung vào những việc thực sự quan trọng. Ứng dụng kết hợp quản lý task thông minh với kỹ thuật Pomodoro và AI Assistant.

## ✨ Tính năng chính

### 🎯 Quản lý Task
- **Tạo và quản lý task** với mức độ ưu tiên (Thấp, Trung bình, Cao, Khẩn cấp)
- **Phân loại theo danh mục**: Công việc, Cá nhân, Học tập, Sức khỏe
- **Subtasks** để chia nhỏ công việc lớn
- **Tags và ghi chú** chi tiết
- **Đính kèm file** và liên kết ngoài
- **Task lặp lại** với cấu hình linh hoạt

### 🏠 Trang chủ thông minh
- Hiển thị **3 task gần nhất** (chưa hoàn thành trước, đã hoàn thành sau)
- **Tổng quan danh mục** với số lượng task
- **Tìm kiếm nhanh** task
- **Nút tạo task/danh mục** tiện lợi

### ⏰ Focus Sessions (Pomodoro)
- **Timer tập trung** với kỹ thuật Pomodoro
- **Theo dõi thời gian** làm việc thực tế
- **Đánh giá năng suất** sau mỗi phiên
- **Thống kê** thời gian tập trung
  
  Cập nhật mới:
  - **Pyramid Timer** với 4 tầng hiển thị tiến trình rõ ràng
  - **Chọn thời gian focus bằng thao tác tap** vào phần hiển thị thời gian (15/25/30/45/60 phút)
  - **Màu nền kim tự tháp**: xám (inactive), **màu active**: tím
  - Chỉ cho phép đổi thời lượng khi timer đang ở trạng thái dừng

### 📅 Lịch và Thời gian
- **Calendar view** để xem task theo ngày
- **Deadline tracking** và nhắc nhở
- **Thống kê năng suất** theo thời gian

### 👤 Quản lý tài khoản
- **Profile cá nhân** với avatar
- **Cài đặt ứng dụng** (theme, ngôn ngữ, múi giờ)
- **Cài đặt Pomodoro** tùy chỉnh
- **Thông báo và nhắc nhở**

### 🤖 AI Assistant
- **Tích hợp Google Generative AI**
- **Gợi ý tối ưu** công việc
- **Phân tích năng suất**

## 🛠️ Công nghệ sử dụng

### Frontend
 - **Flutter** - Framework UI đa nền tảng
 - **Dart** - Ngôn ngữ lập trình
 - **Material Design 3** - Hệ thống thiết kế

### State Management & Navigation
 - **Provider** - Quản lý state
 - **GoRouter** - Navigation 2.0

### Backend & Database
 - **Supabase** - Backend-as-a-Service
- **PostgreSQL** - Database chính
 - **SQLite (sqflite)** - Local database
 - **SharedPreferences** - Local storage

### AI & External Services
 - **Google Generative AI** - AI Assistant
- **Firebase** - Push notifications (planned)

### UI/UX Libraries
 - **Google Fonts** - Typography
 - **Flutter SVG** - Vector graphics
 - **Table Calendar** - Calendar widget
 - **Image Picker** - Media selection

### Utilities
 - **Intl** - Internationalization
 - **UUID** - Unique identifiers
 - **URL Launcher** - External links
 - **Equatable** - Value equality
 - **Flutter DotEnv** - Environment variables

## 📁 Cấu trúc dự án

```
zendo_app/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app.dart                  # App configuration & routing
│   ├── models/                   # Data models
│   │   ├── task.dart
│   │   ├── category.dart
│   │   └── focus_session.dart
│   ├── screens/                  # UI Screens
│   │   ├── auth/                 # Authentication
│   │   ├── home/                 # Trang chủ
│   │   ├── tasks/                # Quản lý task
│   │   ├── focus/                # Focus sessions
│   │   ├── calendar/             # Lịch
│   │   ├── account/              # Tài khoản
│   │   └── ai_chat/              # AI Assistant
│   ├── widgets/                  # Reusable widgets
│   ├── services/                 # Business logic
│   ├── providers/                # State management
│   ├── utils/                    # Utilities
│   └── theme/                    # App theming
├── assets/                       # Static assets
├── Tài liệu/                     # Project documentation
└── README.md
```

## 🚀 Cài đặt và chạy

### Yêu cầu hệ thống
- Flutter SDK ^3.9.2
- Dart SDK
- Android Studio / VS Code
- Git

### Các bước cài đặt

1. **Clone repository**
```bash
git clone https://github.com/bnhminh1010/ZenDo-Focus-on-what-truly-matters.git
cd ZenDo-Focus-on-what-truly-matters/zendo_app
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Cấu hình Supabase/Environment**
- Mặc định, cấu hình Supabase được đặt trong `lib/config/supabase_config.dart` (URL và `anonKey`).
- Nếu bạn sử dụng `.env`, đảm bảo đã cấu hình theo `flutter_dotenv` và đồng bộ với các file cấu hình.

4. **Chạy ứng dụng**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

### Cấu hình Supabase

1. Tạo project trên [Supabase](https://supabase.com)
2. Cập nhật `url` và `anonKey` trong file `lib/config/supabase_config.dart`
3. Import database schema từ `zendo_complete_database_schema.sql`

## 📊 Database Schema

### Bảng chính
- **profiles** - Thông tin người dùng mở rộng
- **categories** - Danh mục công việc
- **tasks** - Công việc chính với đầy đủ metadata
- **subtasks** - Công việc con
- **focus_sessions** - Phiên tập trung Pomodoro
- **user_settings** - Cài đặt cá nhân

### Enum Types
- `task_priority`: low, medium, high, urgent
- `task_status`: pending, in_progress, completed, cancelled
- `focus_session_status`: active, paused, completed, cancelled

Chi tiết schema xem tại: `Tài liệu/ZenDo_Database_Schema_Documentation.md`

## 🎨 UI/UX Design

### Design System
- **Material Design 3** với custom color scheme
- **Responsive design** cho mọi kích thước màn hình
- **Dark/Light theme** support
- **Accessibility** features

### Key Screens
- **Splash Screen** - Màn hình khởi động
- **Authentication** - Đăng nhập/Đăng ký
- **Home** - Trang chủ với recent tasks
- **Task List** - Danh sách task đầy đủ
- **Task Detail** - Chi tiết và chỉnh sửa task
- **Focus Timer** - Pomodoro timer
- **Calendar** - Xem task theo lịch
- **Profile** - Quản lý tài khoản

## 🔄 Tính năng đang phát triển

- [ ] **Collaboration** - Chia sẻ task với team
- [ ] **Advanced Analytics** - Báo cáo năng suất chi tiết
- [ ] **Habit Tracking** - Theo dõi thói quen
- [ ] **Offline Support** - Hoạt động offline
- [ ] **Widget** - Home screen widget
- [ ] **Wear OS** - Hỗ trợ smartwatch
- [ ] **Web App** - Phiên bản web

## 🤝 Đóng góp

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

### Coding Standards
- Tuân thủ [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Sử dụng `flutter analyze` để kiểm tra code
- Viết tests cho các tính năng mới
- Comment code bằng tiếng Việt cho dễ hiểu

## 📄 License

Hiện chưa phát hành giấy phép công khai. Nội dung giấy phép sẽ được cập nhật sau.

## 📞 Liên hệ & Hỗ trợ

- **Email hỗ trợ**: pata10102004@gmail.com
- **Email khẩn cấp**: khoanguyen1.140490@gmail.com
- **GitHub**: [ZenDo Repository](https://github.com/bnhminh1010/ZenDo-Focus-on-what-truly-matters)
- **Cộng đồng**: https://community.zendo.app

## 👥 Đội ngũ phát triển

### **Core Development Team**

- **🚀 Project Manager & Lead Developer**: Nguyễn Bình Minh
  - Quản lý dự án, phát triển backend và database architecture
  - Chịu trách nhiệm về system design và technical decisions

- **💻 Frontend Developer & UI/UX Specialist**: Lại Vũ Hoàng Minh  
  - Phát triển giao diện người dùng với Flutter
  - Thiết kế UX/UI và responsive design
  - Tối ưu hóa performance cho mobile app

- **🔧 Full-Stack Developer & DevOps**: Nguyễn Hoàng Anh Khoa
  - Phát triển tính năng full-stack
  - Quản lý deployment và CI/CD
  - Integration testing và quality assurance

### **Vai trò và Trách nhiệm**
- **Backend & Database**: Nguyễn Bình Minh
- **Frontend & Design**: Lại Vũ Hoàng Minh
- **Integration & Testing**: Nguyễn Hoàng Anh Khoa

---

<div align="center">
  <p><strong>ZenDo - Focus on what truly matters</strong></p>
  <p>Made with ❤️ by ZenDo Team</p>
</div>
