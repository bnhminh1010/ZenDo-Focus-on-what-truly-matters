# TÀI LIỆU TÓM TẮT NHANH - ZenDo App

## 🚀 OVERVIEW 30 GIÂY

**ZenDo** là ứng dụng quản lý công việc với focus timer (Pomodoro), được xây dựng bằng:
- **Flutter** (cross-platform mobile app)
- **Supabase** (Backend-as-a-Service: Database + Auth + Realtime + Storage)
- **Provider** (State management)
- **GoRouter** (Navigation)
- **Gemini AI** (AI assistant)

---

## 📂 CẤU TRÚC CODEBASE

```
lib/
├── main.dart              # Entry point, initialize Supabase
├── app.dart               # App config, Providers, Routing
├── config/                # Environment, API keys
├── models/                # Data models (Task, Category, FocusSession...)
├── providers/             # State management (TaskModel, AuthModel...)
├── services/              # Business logic, API calls
├── screens/               # UI screens
└── widgets/               # Reusable components
```

---

## 🔥 LUỒNG HOẠT ĐỘNG CHÍNH

### 1. Khởi động App
```
main.dart 
  → Initialize Supabase
  → Setup error handlers
  → runApp(ZendoApp())
    → MultiProvider setup
    → GoRouter config
      → /splash (2.5s) → /login → /home
```

### 2. Authentication
```
SignInPage
  → User nhập email/password
  → AuthModel.signIn()
    → SupabaseAuthService.signIn()
      → Supabase.auth.signInWithPassword()
        → Success → Navigate to /home
```

### 3. Quản lý Task
```
HomePage
  → User tạo task
  → TaskModel.addTask(task)
    → SupabaseDatabaseService.createTask()
      → Supabase INSERT INTO tasks
        → Realtime broadcast
          → TaskModel subscription callback
            → UI auto-refresh
```

### 4. Focus Session
```
FocusPage
  → User bắt đầu focus
  → FocusSessionModel.startSession()
    → SupabaseDatabaseService.createFocusSession()
      → Timer countdown
        → Complete/Cancel → updateFocusSession()
```

---

## 🎯 CÁC CLASS QUAN TRỌNG

### Models
- **Task**: Công việc cần làm
- **Category**: Danh mục task
- **FocusSession**: Phiên tập trung/Pomodoro

### Providers (State Management)
- **AuthModel**: Quản lý authentication
- **TaskModel**: Quản lý danh sách tasks
- **FocusSessionModel**: Quản lý focus sessions

### Services
- **SupabaseDatabaseService**: CRUD operations với database
- **SupabaseAuthService**: Authentication với Supabase
- **GeminiAIService**: Chat với AI assistant

### Screens
- **SplashPage**: Màn hình khởi động
- **SignInPage**: Đăng nhập
- **HomePage**: Dashboard chính
- **FocusPage**: Pomodoro timer

---

## 📊 DATA FLOW

```
UI Action
  ↓
Provider Method (e.g., TaskModel.addTask)
  ↓
Service Method (e.g., SupabaseDatabaseService.createTask)
  ↓
Supabase Client API
  ↓
Supabase Backend (PostgreSQL)
  ↓
Realtime Event
  ↓
Provider Subscription Callback
  ↓
notifyListeners()
  ↓
Consumer<Provider> Rebuild
  ↓
UI Update
```

---

## 🔑 KEY CONCEPTS

### 1. Provider Pattern
```dart
// Create Provider
class TaskModel extends ChangeNotifier {
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners(); // Trigger rebuild
  }
}

// Use Provider
Consumer<TaskModel>(
  builder: (context, taskModel, child) {
    return Text('Tasks: ${taskModel.tasks.length}');
  },
)
```

### 2. Supabase Realtime
```dart
// Subscribe to changes
_supabase.channel('tasks_channel')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    table: 'tasks',
    callback: (payload) {
      // Auto-refresh when data changes
    },
  )
  .subscribe();
```

### 3. Immutable Models
```dart
// Cannot modify directly
task.title = "New"; // ❌ Error

// Use copyWith
final updated = task.copyWith(title: "New"); // ✅ Correct
```

---

## 🎓 CÂU HỎI THƯỜNG GẶP

### Q1: App chạy như thế nào khi khởi động?
**A**: `main.dart` → Initialize Supabase → Load environment config → Setup error handlers → Run `ZendoApp()` → MultiProvider setup → GoRouter redirect logic → Show `/splash` → Auto navigate to `/login` hoặc `/home` tùy auth state.

### Q2: Làm sao task tự động sync giữa các device?
**A**: Supabase Realtime. Khi device A tạo/update/delete task, Supabase broadcast event đến tất cả devices đang subscribe. Mỗi device nhận event và tự động refresh UI.

### Q3: Provider hoạt động ra sao?
**A**: Provider là singleton instance quản lý state. Khi state thay đổi, Provider gọi `notifyListeners()` → Tất cả `Consumer<Provider>` widgets tự động rebuild với data mới.

### Q4: Sự khác biệt giữa Model và Provider?
**A**: 
- **Model**: Data structure (Task, Category...) - WHAT (cái gì)
- **Provider**: State management - HOW (làm thế nào)

### Q5: Service layer có vai trò gì?
**A**: Abstraction layer giữa Provider và Backend. Xử lý API calls, error handling, data transformation. Provider gọi Service, Service gọi Supabase.

### Q6: Tại sao dùng copyWith() thay vì modify trực tiếp?
**A**: Immutability pattern. Models có tất cả fields là `final` → không thể modify. Phải tạo instance mới với `copyWith()`. Giúp code dễ debug, tránh side effects.

### Q7: Authentication flow hoạt động ra sao?
**A**: 
1. User nhập email/password
2. `AuthModel.signIn()` → `SupabaseAuthService`
3. Supabase verify credentials
4. Return JWT token
5. Save session
6. Navigate to `/home`

### Q8: Realtime subscription work như thế nào?
**A**: WebSocket connection. App subscribe to specific table/channel. Khi có INSERT/UPDATE/DELETE, Supabase push event qua WebSocket. App callback nhận event và update UI.

### Q9: Làm sao để tạo một task mới?
**A**:
```dart
// 1. User click "Tạo Task"
// 2. Show AddTaskDialog
// 3. User nhập info
// 4. Call:
final task = Task(
  id: uuid.v4(),
  title: 'Learn Flutter',
  category: TaskCategory.learning,
  priority: TaskPriority.high,
  createdAt: DateTime.now(),
);

await taskModel.addTask(task);
// 5. TaskModel → Service → Supabase → Realtime → UI refresh
```

### Q10: Config files dùng để làm gì?
**A**: 
- **EnvironmentConfig**: Môi trường (dev/prod), feature flags
- **AppConfig**: Constants (padding, animation duration...)
- **SupabaseConfig**: Backend credentials (URL, API key)

---

## 🔥 TOP 10 FILES CẦN NHỚ

1. **main.dart** - Entry point
2. **app.dart** - App setup, routing
3. **task.dart** (model) - Task data structure
4. **task_model.dart** (provider) - Task state management
5. **supabase_database_service.dart** - Database operations
6. **supabase_auth_service.dart** - Authentication
7. **home_page.dart** - Main screen
8. **sign_in_page.dart** - Login screen
9. **environment_config.dart** - Environment settings
10. **theme.dart** - App theming

---

## 🎯 KIẾN TRÚC TỔNG QUAN

```
┌─────────────────────────────────────┐
│          ZenDo Flutter App          │
├─────────────────────────────────────┤
│  UI Layer (Screens & Widgets)       │
├─────────────────────────────────────┤
│  State Layer (Providers)            │
├─────────────────────────────────────┤
│  Business Logic Layer (Services)    │
├─────────────────────────────────────┤
│  Data Layer (Models)                │
└─────────────────────────────────────┘
           ↕ (API calls)
┌─────────────────────────────────────┐
│         Supabase Backend            │
│  - PostgreSQL Database              │
│  - Authentication                   │
│  - Realtime Subscriptions           │
│  - Storage                          │
└─────────────────────────────────────┘
```

---

## 🚀 QUICK REFERENCE

### Tạo Task
```dart
await context.read<TaskModel>().addTask(task);
```

### Lấy danh sách Tasks
```dart
final tasks = context.watch<TaskModel>().tasks;
```

### Đăng nhập
```dart
await context.read<AuthModel>().signIn(email, password);
```

### Navigation
```dart
context.go('/home');
context.push('/task/:id', extra: task);
```

### Realtime Subscribe
```dart
_supabase.channel('tasks').onPostgresChanges(
  event: PostgresChangeEvent.all,
  table: 'tasks',
  callback: (payload) { /* handle */ },
).subscribe();
```

---

## ✅ CHECKLIST ÔN TẬP

- [ ] Hiểu luồng khởi động app (main → app → routing)
- [ ] Biết Provider pattern hoạt động thế nào
- [ ] Nắm được data flow (UI → Provider → Service → Supabase)
- [ ] Hiểu Realtime synchronization
- [ ] Biết authentication flow
- [ ] Nắm được CRUD operations cho Task
- [ ] Hiểu vai trò của từng layer (Models, Providers, Services, UI)
- [ ] Biết config files làm gì
- [ ] Hiểu immutability pattern
- [ ] Nắm được GoRouter navigation

---

**💡 TIP**: In file này ra, đọc trước buổi vấn đáp 15 phút. Bạn sẽ tự tin hơn nhiều!

✅ **Chúc bạn vấn đáp tốt!**
