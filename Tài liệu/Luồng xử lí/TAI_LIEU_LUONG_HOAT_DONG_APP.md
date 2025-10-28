# TÀI LIỆU LUỒNG HOẠT ĐỘNG ZenDo APP

## 📋 MỤC LỤC
1. [Tổng quan kiến trúc](#tổng-quan-kiến-trúc)
2. [Luồng khởi động ứng dụng](#luồng-khởi-động-ứng-dụng)
3. [Luồng xác thực người dùng](#luồng-xác-thực-người-dùng)
4. [Luồng quản lý Task](#luồng-quản-lý-task)
5. [Luồng Focus Session](#luồng-focus-session)
6. [Sơ đồ kiến trúc tổng quan](#sơ-đồ-kiến-trúc)

---

## 🏗️ TỔNG QUAN KIẾN TRÚC

### Cấu trúc thư mục
```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App configuration & routing
├── config/                      # Cấu hình môi trường
├── models/                      # Data models
├── providers/                   # State management (Provider)
├── services/                    # Business logic & API calls
├── screens/                     # UI screens
├── widgets/                     # Reusable widgets
└── utils/                       # Helper functions
```

### Tech Stack
- **Framework**: Flutter
- **Backend**: Supabase (PostgreSQL + Realtime + Auth + Storage)
- **State Management**: Provider
- **Routing**: GoRouter
- **AI Integration**: Google Gemini AI

---

## 🚀 LUỒNG KHỞI ĐỘNG ỨNG DỤNG

### 1. main.dart → Điểm vào ứng dụng

**Thứ tự thực thi:**
```
main() 
  ↓
[1] Setup error handlers
  ↓
[2] WidgetsFlutterBinding.ensureInitialized()
  ↓
[3] Load environment config (.env)
  ↓
[4] Initialize Supabase client
  ↓
[5] Configure SystemUI (status bar, orientation)
  ↓
[6] runApp(ZendoApp())
```

**Chi tiết:**

1. **Error Handling Setup** (dòng 24-40)
   - `FlutterError.onError`: Bắt lỗi Flutter framework
   - `PlatformDispatcher.instance.onError`: Bắt lỗi async

2. **Environment Loading** (dòng 50-59)
   - Chỉ load `.env` trong development mode
   - Sử dụng `flutter_dotenv` package

3. **Supabase Initialization** (dòng 62-69)
   - URL: từ `SupabaseConfig.url`
   - Anon Key: từ `SupabaseConfig.anonKey`
   - Auth flow: PKCE (cho desktop OAuth)

4. **UI Configuration** (dòng 72-85)
   - Status bar: transparent
   - Orientation: portrait only

---

### 2. app.dart → Cấu hình ứng dụng

**Provider Setup:**
```dart
MultiProvider(
  providers: [
    AuthModel,              // Quản lý authentication
    GoogleSignInProvider,   // Google OAuth
    GitHubSignInProvider,   // GitHub OAuth
    TaskModel,              // Quản lý tasks
    CategoryModel,          // Quản lý categories
    FocusSessionModel,      // Quản lý focus sessions
    SettingsModel,          // Cài đặt ứng dụng
    ThemeProvider,          // Dark/Light mode
  ]
)
```

**Routing Configuration:**
```
GoRouter(
  initialLocation: '/splash'
  redirect: (context, state) => {
    - Kiểm tra authentication
    - Redirect đến /login nếu chưa đăng nhập
    - Redirect đến /home nếu đã đăng nhập
  }
)
```

---

## 🔐 LUỒNG XÁC THỰC NGƯỜI DÙNG

### Màn hình Splash → Sign In → Home

```
┌─────────────────┐
│  SplashPage     │ (2.5s animation)
│  splash_page.dart│
└────────┬────────┘
         │
         ↓ (context.go('/login'))
┌─────────────────┐
│  SignInPage     │
│ sign_in_page.dart│
└────────┬────────┘
         │
         ↓ [User nhập email/password]
┌─────────────────┐
│   AuthModel     │ ← signIn(email, pass)
│ auth_model.dart │
└────────┬────────┘
         │
         ↓ Gọi service
┌───────────────────────┐
│ SupabaseAuthService   │
│supabase_auth_service  │
└───────────┬───────────┘
            │
            ↓ API call
┌───────────────────────┐
│  Supabase Backend     │
│  - Verify credentials │
│  - Create session     │
│  - Return JWT token   │
└───────────┬───────────┘
            │
            ↓ Success
┌───────────────────────┐
│    HomePage           │
│   home_page.dart      │
└───────────────────────┘
```

### Chi tiết AuthModel flow:

**1. Initialize** (khi app khởi động)
```dart
AuthModel.initialize()
  ↓
Kiểm tra session hiện tại
  ↓
Nếu có session → isAuthenticated = true
  ↓
Load user info & avatar
```

**2. Sign In Process**
```dart
signIn(email, password)
  ↓
_authService.signIn()
  ↓
Supabase.auth.signInWithPassword()
  ↓
Nếu thành công:
  - Lưu user info
  - Load avatar từ profiles table
  - notifyListeners()
  - return true
```

**3. Social Login (Google/GitHub)**
```dart
GoogleSignInProvider.signIn()
  ↓
Google OAuth flow
  ↓
Exchange token với Supabase
  ↓
Update AuthModel state
```

---

## 📝 LUỒNG QUẢN LÝ TASK

### Tạo Task mới

```
HomePage (nhấn "Tạo Task")
  ↓
AddTaskDialog hiển thị
  ↓
User nhập thông tin:
  - Title
  - Description  
  - Category
  - Priority
  - Due Date
  ↓
TaskModel.addTask(task)
  ↓
SupabaseDatabaseService.createTask(task)
  ↓
Supabase INSERT vào bảng 'tasks'
  ↓
Realtime subscription tự động cập nhật
  ↓
UI refresh với task mới
```

### Chi tiết TaskModel operations:

**1. Initialize**
```dart
TaskModel.initialize()
  ↓
loadTasks() - Load từ Supabase
  ↓
_setupRealtimeSubscription()
  ↓
Lắng nghe mọi thay đổi từ database
```

**2. CRUD Operations**

**CREATE:**
```dart
addTask(task)
  ↓
Validate user authentication
  ↓
_databaseService.createTask(task)
  ↓
Supabase INSERT với user_id
  ↓
Realtime update → UI refresh
```

**READ:**
```dart
getTasks()
  ↓
SELECT * FROM tasks WHERE user_id = currentUserId
  ↓
Convert Supabase data → Task objects
  ↓
Return List<Task>
```

**UPDATE:**
```dart
updateTask(updatedTask)
  ↓
_databaseService.updateTask(id, task)
  ↓
Supabase UPDATE WHERE id = taskId AND user_id = currentUserId
  ↓
Realtime update → UI refresh
```

**DELETE:**
```dart
deleteTask(taskId)
  ↓
_databaseService.deleteTask(taskId)
  ↓
Supabase DELETE WHERE id = taskId AND user_id = currentUserId
  ↓
Realtime update → UI refresh
```

**3. Realtime Subscription**
```dart
subscribeToTasks((updatedTasks) {
  _tasks.clear();
  _tasks.addAll(updatedTasks);
  notifyListeners();
})
```

### Task Data Flow

```
User Action (UI)
  ↓
TaskModel (Provider)
  ↓
SupabaseDatabaseService
  ↓
Supabase Backend
  ↓
PostgreSQL Database
  ↓
Realtime Update
  ↓
TaskModel nhận update
  ↓
notifyListeners()
  ↓
Consumer<TaskModel> rebuild
  ↓
UI cập nhật
```

---

## ⏱️ LUỒNG FOCUS SESSION

### Bắt đầu phiên Focus

```
HomePage/FocusPage
  ↓
Chọn task để focus
  ↓
FocusSessionModel.startSession(task)
  ↓
Tạo FocusSession object
  ↓
SupabaseDatabaseService.createFocusSession()
  ↓
INSERT vào bảng 'focus_sessions'
  ↓
Start timer countdown
  ↓
[Timer running...]
  ↓
Session kết thúc:
  - Completed: actualDurationMinutes = plannedDuration
  - Cancelled: status = cancelled
  ↓
updateFocusSession()
  ↓
UPDATE status, endedAt, actualDurationMinutes
```

### FocusSession States

```
┌──────────┐     pause()      ┌──────────┐
│  ACTIVE  │ ─────────────→  │  PAUSED  │
└─────┬────┘                  └────┬─────┘
      │                            │
      │ complete()     resume()    │
      ↓                            ↓
┌──────────┐                  ┌──────────┐
│COMPLETED │                  │  ACTIVE  │
└──────────┘                  └──────────┘
      │
      │ cancel()
      ↓
┌──────────┐
│CANCELLED │
└──────────┘
```

---

## 🗂️ SƠ ĐỒ KIẾN TRÚC TỔNG QUAN

```
┌─────────────────────────────────────────────────────┐
│                    ZenDo App                        │
│                   (Flutter)                         │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
┌───────▼────────┐   ┌────────▼────────┐
│   UI Layer     │   │  State Layer    │
│   (Screens &   │   │   (Providers)   │
│    Widgets)    │   │                 │
└───────┬────────┘   └────────┬────────┘
        │                     │
        │         ┌───────────┴────────────┐
        │         │                        │
        │    ┌────▼─────┐         ┌───────▼──────┐
        │    │  Models  │         │   Services   │
        │    └──────────┘         └───────┬──────┘
        │                                 │
        └─────────────────────────────────┤
                                          │
                           ┌──────────────▼──────────────┐
                           │    Supabase Backend         │
                           │  - PostgreSQL Database      │
                           │  - Realtime Subscriptions   │
                           │  - Authentication           │
                           │  - Storage                  │
                           └─────────────────────────────┘
```

### Layer Responsibilities:

**UI Layer (Screens & Widgets):**
- Hiển thị dữ liệu
- Nhận user input
- Gọi Provider methods

**State Layer (Providers):**
- Quản lý app state
- Business logic
- Gọi Services
- Notify UI khi có thay đổi

**Models:**
- Define data structure
- Serialization/Deserialization
- Data validation

**Services:**
- API calls
- Database operations
- External integrations (Google, GitHub, Gemini AI)

**Supabase Backend:**
- Data persistence
- Realtime updates
- User authentication
- File storage

---

## 📊 LUỒNG DỮ LIỆU CHI TIẾT

### Example: User tạo một task mới

```
1. HomePage
   └─> User nhấn "Tạo Task"
       │
2. AddTaskDialog
   └─> User nhập: "Học Flutter", Category: Learning, Priority: High
       │
3. TaskModel.addTask()
   └─> Tạo Task object với UUID
       │
4. SupabaseDatabaseService.createTask()
   └─> Prepare data: toSupabaseMap() + add user_id + timestamps
       │
5. Supabase Client
   └─> INSERT INTO tasks (...) VALUES (...)
       │
6. PostgreSQL Database
   └─> Row inserted với id mới
       │
7. Realtime Channel
   └─> Broadcast event: INSERT
       │
8. TaskModel subscription callback
   └─> Nhận event, gọi getTasks()
       │
9. Load updated tasks từ DB
   └─> Convert từ Supabase Map → Task objects
       │
10. TaskModel.notifyListeners()
    └─> Trigger rebuild cho tất cả Consumer<TaskModel>
        │
11. HomePage (Consumer<TaskModel>)
    └─> Rebuild với task list mới
        │
12. UI hiển thị task "Học Flutter" trong danh sách
```

**Thời gian thực hiện**: ~200-500ms (tùy network latency)

---

## 🔄 REALTIME SYNCHRONIZATION

### Cơ chế Realtime của Supabase

```
Client A                    Supabase Server              Client B
   │                              │                          │
   │ UPDATE task                  │                          │
   ├──────────────────────────────>│                          │
   │                              │                          │
   │                              │ Broadcast to subscribers │
   │                              ├─────────────────────────>│
   │                              │                          │
   │                              │                     onUpdate()
   │                              │                     reload tasks
   │                              │                     UI refresh
```

### Các bảng có Realtime:
- ✅ `tasks`
- ✅ `categories`  
- ✅ `focus_sessions`
- ✅ `profiles`

---

## 🎯 CÁC PATTERNS SỬ DỤNG

### 1. Provider Pattern (State Management)
```dart
Provider<AuthModel>
  - Singleton instance
  - notifyListeners() khi state thay đổi
  - Consumer<AuthModel> tự động rebuild
```

### 2. Repository Pattern (Services)
```dart
SupabaseDatabaseService
  - Tập trung tất cả database operations
  - Abstraction layer giữa Provider và Supabase
  - Error handling tập trung
```

### 3. Factory Constructor Pattern (Models)
```dart
Task.fromSupabaseMap(map)
  - Parse data từ database
  - Handle null values
  - Type conversion
```

### 4. Immutable Data Pattern (Models)
```dart
class Task {
  final String id;
  final String title;
  // ... all fields are final
  
  Task copyWith({...}) // Create new instance
}
```

---

## 🚦 ERROR HANDLING

### Các lớp error handling:

**1. UI Level:**
```dart
try {
  await taskModel.addTask(task);
  showSuccessSnackBar();
} catch (e) {
  showErrorSnackBar(e.message);
}
```

**2. Provider Level:**
```dart
try {
  await _service.createTask(task);
  notifyListeners();
} catch (e) {
  debugPrint('Error: $e');
  rethrow; // Pass to UI
}
```

**3. Service Level:**
```dart
try {
  await _supabase.from('tasks').insert(data);
} on TimeoutException {
  throw Exception('Connection timeout');
} on PostgrestException {
  throw Exception('Database error');
} catch (e) {
  throw Exception('Unknown error: $e');
}
```

---

## 📱 NAVIGATION FLOW

```
/splash (2.5s)
  │
  ↓ Not authenticated
/login
  │
  ├─> /register (nếu chưa có tài khoản)
  │
  ↓ Login successful
/home (với BottomNavigationBar)
  ├─> /calendar
  ├─> /focus
  └─> /account
      ├─> /profile
      ├─> /security
      ├─> /notifications
      └─> /settings
```

### Stack Navigation:
```
/home → /tasks → /task/:id (detail)
/home → /categories → /category/:name
/home → /ai-chat
```

---

## 🎨 THEME & STYLING

**Theme Provider:**
- Light mode / Dark mode
- System default
- Persistent preference

**Glass Morphism:**
- GlassContainer widget
- Backdrop blur effect
- Semi-transparent backgrounds

---

**Tài liệu này cung cấp cái nhìn tổng quan về luồng hoạt động của ZenDo App. Khi giảng viên hỏi về một tính năng cụ thể, bạn có thể tham khảo phần tương ứng để giải thích chi tiết.**
