# TÀI LIỆU CHI TIẾT: WIDGETS

## 📁 Thư mục: `lib/widgets/`

Thư mục Widgets tập hợp các thành phần UI tái sử dụng, đóng vai trò “xương sống” tạo nên giao diện glassmorphism của ZenDo.

---

## 1️⃣ Nhóm nền tảng Glassmorphism

### `glass_container.dart`
- **Class chính**: `GlassContainer`
- **Mục đích**: Container với hiệu ứng kính mờ (blur, gradient, border highlight, inner shadow).
- **Khi nào dùng**: Bao bọc card/nút/giao diện cần nổi bật.
- **Tuỳ chỉnh**: `borderRadius`, `blur`, `opacity`, `pill`, `highlightEdge`, `innerShadow`, `gradient`, `boxShadow`…

### `glass_button.dart`
- **Class**: `GlassButton`, `GlassIconButton`, `GlassElevatedButton`, `GlassTextButton`
- **Mục đích**: Bộ nút glass với animation scale/opacity khi nhấn.
- **Khi nào dùng**: Các action button phong cách glass.

### `glass_dialog.dart`
- **Class**: `GlassDialog`
- **Mục đích**: Dialog nền glass, bo tròn, blur.
- **Khi nào dùng**: Popup confirm, form nhỏ, thông báo.

---

## 2️⃣ Widgets tương tác Task

### `add_task_dialog.dart`
- **Class**: `AddTaskDialog`
- **Mục đích**: Dialog tạo/chỉnh sửa Task đầy đủ (title, description, category, priority, due date, tags, image upload, focus time).
- **Logic**: Quản lý form (`GlobalKey<FormState>`), gọi `TaskModel` để tạo/cập nhật, sử dụng `ImageStorageService` upload ảnh.

### `task_card.dart`
- **Class**: `TaskCard`
- **Mục đích**: Card hiển thị summary task (title, description, priority badge, due date, checkbox toggle).
- **Khi nào dùng**: Danh sách tasks (HomePage, TaskListPage…)

### `task_list_view.dart`
- **Class**: `TaskListView`
- **Mục đích**: Danh sách task có filter, grouped section, layout responsive.
- **Khi nào dùng**: TaskListPage hiển thị nhiều tasks theo trạng thái/category.

### `subtask_list_widget.dart`
- **Class**: `SubtaskListWidget`
- **Mục đích**: Quản lý danh sách subtasks trong TaskDetail (thêm/xoá/mark complete, drag reorder).

---

## 3️⃣ Widgets hỗ trợ Focus / Pomodoro

### `pomodoro_timer_widget.dart`
- **Class**: `PomodoroTimerWidget`
- **Mục đích**: Giao diện timer Pomodoro với trạng thái (work/break), animation progress, điều khiển start/pause/resume/reset.
- **Khi nào dùng**: FocusPage.

### `pomodoro_timer.dart`
- **Class**: `PomodoroTimer`
- **Mục đích**: Logic thuần (countdown, trạng thái, callback), không UI. Được PomodoroTimerWidget sử dụng.

### `progress_circle.dart`
- **Class**: `ProgressCircle`
- **Mục đích**: Vòng tròn hiển thị tiến độ (dùng trong timer, stats).

### `circular_time_picker.dart`
- **Class**: `CircularTimePicker`
- **Mục đích**: Chọn thời gian (phút) dạng vòng tròn đồ hoạ cho Pomodoro.

### `pyramid_timer_widget.dart`
- **Class**: `PyramidTimerWidget`
- **Mục đích**: Timer dạng tháp (Pyramid method), hiển thị các “layer” work/break.

---

## 4️⃣ Widgets trạng thái (Loading / Empty / Error)

### `loading_state_widget.dart`
- **Class**: `LoadingStateWidget` (và biến thể `LoadingButton`, `LoadingPlaceholder`)
- **Mục đích**: Hiển thị trạng thái loading với animation shimmer, animate button khi đang submit.

### `enhanced_loading_widget.dart`
- **Class**: `EnhancedLoadingWidget`
- **Mục đích**: Loading với particle animation, text tuỳ chỉnh.

### `enhanced_empty_state_widget.dart`
- **Class**: `EnhancedEmptyStateWidget`
- **Mục đích**: Empty state hiện đại (emoji, glass background, action button).

### `error_state_widget.dart`
- **Class**: `ErrorStateWidget`
- **Mục đích**: Hiển thị lỗi (icon + message + action), có biến thể `.empty` để reuse.

### `skeleton_loader.dart`
- **Class**: `SkeletonLoader`
- **Mục đích**: Placeholder skeleton shimmer cho list card/task/kpi.

---

## 5️⃣ Widgets Social Sign-in

### `google_signin_button.dart`
- **Class**: `GoogleSignInButton`
- **Mục đích**: Nút đăng nhập Google với logo chuẩn, loading state, callback success.

### `github_signin_button.dart`
- **Class**: `GitHubSignInButton`
- **Mục đích**: Nút đăng nhập GitHub (icon + label + loading), gọi `GitHubSignInProvider`.

---

## 6️⃣ Widgets hỗ trợ UI/UX khác

### `micro_animations.dart`
- **Class/Functions**: tập hợp animation helpers (fade/slide/bounce, hero-like transition).
- **Khi nào dùng**: Thêm animation nhỏ cho list item, button.

### `haptic_feedback_widget.dart`
- **Class**: `HapticFeedbackWidget`
- **Mục đích**: Wrap widget để đồng bộ haptic feedback khi tương tác.

### `category_form_dialog.dart`
- **Class**: `CategoryFormDialog`
- **Mục đích**: Dialog tạo/sửa Category (icon picker, color picker, validate).

### `password_strength_indicator.dart`
- **Class**: `PasswordStrengthIndicator`
- **Mục đích**: Đánh giá độ mạnh mật khẩu (SignUp).

### `theme_aware_logo.dart`
- **Class**: `AnimatedThemeAwareLogo`
- **Mục đích**: Logo ZenDo thay đổi màu/animation theo theme sáng/tối.

---

## 🔄 Phụ thuộc điển hình giữa Widgets
```
AddTaskDialog → GlassDialog + GlassButton + GlassContainer + LoadingStateWidget + ImagePicker + TaskModel
TaskCard → GlassContainer + TaskModel + Theme
PomodoroTimerWidget → PomodoroTimer (logic) + ProgressCircle + GlassButton
AIChatPage → GlassButton + GlassContainer + LoadingStateWidget + GeminiAIService
```

---

## 💡 Tips khi đọc Widgets
1. **Xem comment đầu file**: hầu hết widget đã có block chú thích “Tên/Tác dụng/Khi nào dùng”.
2. **Identify dependencies**: Widgets thường import `models/` → data; `providers/` → state; `services/` → logic.
3. **Props chính**: để ý `final` fields, giúp hiểu widget có thể cấu hình thế nào.
4. **State management**: Widgets Statefull → `initState/dispose` (VD: animation controllers, text controllers).
5. **Reusability**: Nhiều widget được tách nhỏ để tái sử dụng trong screens (task list, dialog, button). Khi tuỳ chỉnh UI, ưu tiên sửa widget tái sử dụng thay vì sửa rải rác.

---

✅ **Đã chú thích đầy đủ thư mục widgets!**
