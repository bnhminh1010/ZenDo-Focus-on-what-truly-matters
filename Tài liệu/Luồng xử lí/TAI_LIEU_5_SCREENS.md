# TÀI LIỆU CHI TIẾT: SCREENS

## 📁 Thư mục: `lib/screens/`

Thư mục screens chứa toàn bộ UI chính của ứng dụng, chia theo module tính năng. Mỗi màn hình thường kết hợp Widgets tùy biến + Providers để cập nhật dữ liệu.

---

## 1️⃣ Nhóm Account (`lib/screens/account/`)

| File | Class chính | Mục đích | Khi nào dùng |
|------|-------------|----------|--------------|
| `account_page.dart` | `AccountPage` | Dashboard tài khoản: hiển thị avatar, thông tin user, nhanh tới các trang con (Profile, Notifications, Security, Language, Help). | Người dùng mở tab "Tài khoản" trong bottom navigation. |
| `profile_page.dart` | `ProfilePage` | Form chỉnh sửa thông tin cá nhân (tên, email, avatar) kèm upload ảnh. | Người dùng muốn cập nhật hồ sơ cá nhân. |
| `notifications_page.dart` | `NotificationsPage` | Cài đặt thông báo: toggle push/email/task reminder/daily digest. | Người dùng điều chỉnh loại thông báo nhận được. |
| `security_page.dart` | `SecurityPage` | Cài đặt bảo mật: đổi mật khẩu, xác thực hai bước, session history. | User muốn nâng cao bảo mật tài khoản. |
| `language_page.dart` | `LanguagePage` | Chọn ngôn ngữ hiển thị (Việt, Anh, Nhật, Hàn, Trung...). | Người dùng muốn đổi ngôn ngữ giao diện. |
| `help_page.dart` | `HelpPage` | Trung tâm trợ giúp: FAQ, hướng dẫn, liên hệ support, changelog. | Người dùng cần trợ giúp/hỗ trợ kỹ thuật. |

**Luồng account tổng quát:** `AccountPage` → chọn thẻ → GoRouter điều hướng tới trang con tương ứng.

---

## 2️⃣ Authentication (`lib/screens/auth/`)

| File | Class chính | Mục đích | Khi nào dùng |
|------|-------------|----------|--------------|
| `sign_in_page.dart` | `SignInPage` | Màn hình đăng nhập với form email/password, Google/GitHub, forgot password. | Người dùng chưa đăng nhập. |
| `sign_up_page.dart` | `SignUpPage` | Form đăng ký: tên, email, password, xác nhận password, strength indicator. | Người dùng tạo tài khoản mới. |

**Luồng:** Splash → SignIn → (có link sang SignUp). Sau khi AuthModel trả về thành công → GoRouter navigate `/home`.

---

## 3️⃣ AI (`lib/screens/ai/`)

| File | Class chính | Mục đích | Khi nào dùng |
|------|-------------|----------|--------------|
| `ai_chat_page.dart` | `AIChatPage` | Màn hình chat với trợ lý AI (Gemini). Hỗ trợ gửi text, đính kèm file, gợi ý task từ AI. | Người dùng cần trợ giúp lập kế hoạch, phân tích task, hỏi thói quen focus. |

**Đặc điểm:**
- Tích hợp `GeminiAIService`
- Hiển thị lịch sử hội thoại (`AIMessage` model)
- Có animation typing, upload file, action từ Task extra data.

---

## 4️⃣ Calendar (`lib/screens/calendar/`)

| File | Class chính | Mục đích | Khi nào dùng |
|------|-------------|----------|--------------|
| `calendar_page.dart` | `CalendarPage` | Hiển thị lịch, tasks theo ngày/tuần/tháng. Có heatmap, xem tasks trong ngày. | Người dùng cần nhìn tổng quan lịch làm việc. |

---

## 5️⃣ Categories (`lib/screens/categories/`)

| File | Class chính | Mục đích | Khi nào dùng |
|------|-------------|----------|--------------|
| `categories_list_page.dart` | `CategoriesListPage` | Danh sách danh mục tùy chỉnh, thống kê số task mỗi category. | Người dùng cần xem/duyệt các category. |
| `category_management_page.dart` | `CategoryManagementPage` | Quản lý danh mục: tạo, sửa, xóa, đổi icon/màu. | Người dùng muốn tuỳ chỉnh kategorii. |

---

## 6️⃣ Focus (`lib/screens/focus/`)

| File | Class chính | Mục đích | Khi nào dùng |
|------|-------------|----------|--------------|
| `focus_page.dart` | `FocusPage` | Màn hình Pomodoro: chọn task để focus, chạy timer, log distractions, hiển thị lịch sử session. | Người dùng cần bắt đầu phiên tập trung. |

**Đặc điểm:**
- Sử dụng `PomodoroTimerWidget`
- Gọi `FocusSessionModel` load sessions, `TaskModel` để chọn task
- Interaction: start/pause/resume/complete session.

---

## 7️⃣ Home (`lib/screens/home/`)

| File | Class chính | Mục đích | Khi nào dùng |
|------|-------------|----------|--------------|
| `home_page.dart` | `HomePage` | Dashboard chính: ô tìm kiếm, tạo task/AI chat nhanh, grid categories, danh sách task gần đây, các thống kê. | Người dùng mở app sau khi login. |

**Đặc điểm:**
- Responsive layout (mobile/tablet/desktop)
- Consumer<TaskModel> hiển thị dữ liệu realtime
- Liên kết tới TaskDetail, CategoryDetail, AddTaskDialog.

---

## 8️⃣ Settings (`lib/screens/settings/`)

Hiện `settings_page.dart` là placeholder/tạm. Mục đích: gom các cài đặt chung (theme, accessibility, sync…).

---

## 9️⃣ Splash (`lib/screens/splash/`)

| File | Class chính | Mục đích | Khi nào dùng |
|------|-------------|----------|--------------|
| `splash_page.dart` | `SplashPage` | Màn hình splash 2.5s với animation glassmorphism, logo. Tự điều hướng tới Login hoặc Home tùy auth. | Khởi động app. |

---

## 🔟 Tasks (`lib/screens/tasks/`)

| File | Class chính | Mục đích | Khi nào dùng |
|------|-------------|----------|--------------|
| `task_list_page.dart` | `TaskListPage` | Danh sách tất cả tasks, filter theo trạng thái/category/tag/priority. | Người dùng xem toàn bộ công việc. |
| `task_detail_page.dart` | `TaskDetailPage` | Chi tiết task: mô tả, subtasks, attachments, focus sessions liên quan, actions (complete, edit). | Người dùng nhấn vào một task cụ thể. |
| `category_detail_page.dart` | `CategoryDetailPage` | Danh sách task thuộc một category, hiển thị icon/màu. | Người dùng chọn category từ Home hoặc CategoriesList. |
| `tasks_page.dart` | `TasksPage` | Shell page (có thể là layout chung/placeholder) gom các tab/section tasks. | Khi app cần hiển thị nhiều tab task. |

---

## 🔁 Luồng điều hướng chính
```
Splash → (Check Auth)
  ├─> Login (SignInPage)
  │    └─> SignUp (SignUpPage)
  └─> Home (Bottom Nav Shell)
       ├─ HomePage
       ├─ CalendarPage
       ├─ FocusPage
       └─ AccountPage → {Profile, Notifications, Security, Language, Help}

HomePage/TasksList → TaskDetail/CategoryDetail
HomePage → AIChatPage (qua extra data)
FocusPage → AddTaskDialog → TaskDetail
```

---

## ✅ Best Practices khi đọc code screens
1. **Kiểm tra phần đầu file**: hầu hết đã có block chú thích "Tên/Tác dụng/Khi nào dùng" → dùng làm opening statement.
2. **Xác định dependencies**: import Providers, Services, Widgets nào → hiểu data flow.
3. **Tìm `build()`**: xem layout, semantics, event handler (onTap, onPressed) → biết UI interaction.
4. **Tập trung `initState`, `dispose` (StatefulWidget)**: hiểu lifecycle (VD: FocusPage load sessions trong `addPostFrameCallback`).
5. **Để ý navigation**: `context.goNamed`, `context.push`, `GoRouter` → ghi nhớ route name & path.

---

✅ **Đã chú thích đầy đủ tất cả screens!**
