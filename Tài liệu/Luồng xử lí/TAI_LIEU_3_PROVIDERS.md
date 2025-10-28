# TÀI LIỆU CHI TIẾT: PROVIDERS (STATE MANAGEMENT)

## 📁 Thư mục: `lib/providers/`

### Tổng quan
Providers quản lý state của ứng dụng sử dụng package `provider`. Mỗi Provider extend `ChangeNotifier` và notify listeners khi state thay đổi.

---

## 1️⃣ AuthModel (`auth_model.dart`) [@lib/providers/auth_model.dart#1-252]

### 🎯 Mục đích
Quản lý trạng thái xác thực người dùng, session và profile information.

### 🔑 State Properties

| Property | Type | Description |
|----------|------|-------------|
| `_isAuthenticated` | bool | User đã đăng nhập? |
| `_userEmail` | String? | Email của user |
| `_userName` | String? | Tên hiển thị |
| `_userAvatarUrl` | String? | URL avatar |
| `_isLoading` | bool | Đang xử lý request? |

### 📡 Public Methods

#### `initialize()` [@lib/providers/auth_model.dart#25-61]
**Khi gọi**: App khởi động
**Mục đích**: Kiểm tra session hiện tại
```dart
await authModel.initialize();
// Kiểm tra currentUser từ Supabase
// Load user info & avatar
// Update state
```

**Flow**:
```
1. Gọi _authService.currentUser
2. Nếu có user:
   - Set isAuthenticated = true
   - Load userEmail, userName
   - Load avatarUrl từ profiles table
3. Nếu không:
   - Reset tất cả về null
4. notifyListeners()
```

#### `signIn(String email, String password)` [@lib/providers/auth_model.dart#63-96]
**Returns**: `Future<bool>`
**Mục đích**: Đăng nhập với email/password

```dart
final success = await authModel.signIn(
  'user@example.com',
  'password123',
);

if (success) {
  // Navigate to home
} else {
  // Show error
}
```

**Flow**:
```
1. Set _isLoading = true, notifyListeners()
2. Validate email format
3. Call _authService.signIn()
4. Nếu success:
   - Update _isAuthenticated
   - Load user info & avatar
   - Return true
5. Nếu fail:
   - Return false
6. Finally: _isLoading = false, notifyListeners()
```

#### `signUp(String name, String email, String password)` [@lib/providers/auth_model.dart#98-125]
**Returns**: `Future<bool>`
**Mục đích**: Đăng ký tài khoản mới

```dart
final success = await authModel.signUp(
  'John Doe',
  'john@example.com',
  'securepass',
);
```

**Flow**:
```
1. Call _authService.signUp()
2. Supabase tự động tạo profile (via trigger)
3. Update state nếu thành công
```

#### `signOut()` [@lib/providers/auth_model.dart#127-145]
**Returns**: `Future<void>`
**Mục đích**: Đăng xuất

```dart
await authModel.signOut();
// Navigate to login
```

**Flow**:
```
1. Call _authService.signOut()
2. Reset tất cả state về null/false
3. notifyListeners()
```

#### `updateProfile(String name, String email)` [@lib/providers/auth_model.dart#147-172]
**Returns**: `Future<bool>`
**Mục đích**: Cập nhật thông tin profile

#### `updateProfileWithAvatar(String name, String email, String? avatarUrl)` [@lib/providers/auth_model.dart#174-200]
**Returns**: `Future<bool>`
**Mục đích**: Cập nhật profile kèm avatar

#### `resetPassword(String email)` [@lib/providers/auth_model.dart#202-218]
**Returns**: `Future<bool>`
**Mục đích**: Gửi email reset password

#### `updatePassword(String currentPassword, String newPassword)` [@lib/providers/auth_model.dart#220-241]
**Returns**: `Future<bool>`
**Mục đích**: Đổi mật khẩu

### 🔌 Dependencies
- `SupabaseAuthService`: Xử lý authentication với Supabase
- `ProfileService`: Load avatar và profile data

---

## 2️⃣ TaskModel (`task_model.dart`) [@lib/providers/task_model.dart#1-201]

### 🎯 Mục đích
Quản lý danh sách tasks, CRUD operations và realtime synchronization.

### 🔑 State Properties

| Property | Type | Description |
|----------|------|-------------|
| `_tasks` | List<Task> | Danh sách tất cả tasks |
| `_isLoading` | bool | Đang load data? |
| `_tasksSubscription` | RealtimeChannel? | Realtime subscription |

### 📡 Public Methods

#### `initialize()`
**Khi gọi**: App khởi động hoặc user login
**Mục đích**: Load tasks và setup realtime

```dart
await taskModel.initialize();
```

**Flow**:
```
1. Call loadTasks()
2. Call _setupRealtimeSubscription()
```

#### `loadTasks()` [@lib/providers/task_model.dart#29-46]
**Returns**: `Future<void>`
**Mục đích**: Load tất cả tasks từ Supabase

```dart
await taskModel.loadTasks();
```

**Flow**:
```
1. Set _isLoading = true
2. Call _databaseService.getTasks()
3. Clear _tasks, add all new tasks
4. Set _isLoading = false
5. notifyListeners()
```

#### `addTask(Task task)` [@lib/providers/task_model.dart#94-119]
**Returns**: `Future<void>`
**Mục đích**: Thêm task mới

```dart
final newTask = Task(
  id: uuid.v4(),
  title: 'Learn Flutter',
  category: TaskCategory.learning,
  priority: TaskPriority.high,
  createdAt: DateTime.now(),
);

await taskModel.addTask(newTask);
```

**Flow**:
```
1. Validate user authentication
2. Call _databaseService.createTask()
3. Add task to _tasks list
4. notifyListeners()
5. Realtime sẽ tự động sync cho other devices
```

#### `updateTask(Task updatedTask)` [@lib/providers/task_model.dart#122-144]
**Returns**: `Future<void>`
**Mục đích**: Cập nhật task

```dart
final updated = currentTask.copyWith(
  isCompleted: true,
  completedAt: DateTime.now(),
);

await taskModel.updateTask(updated);
```

#### `deleteTask(String taskId)` [@lib/providers/task_model.dart#147-164]
**Returns**: `Future<void>`
**Mục đích**: Xóa task

```dart
await taskModel.deleteTask(task.id);
```

#### `toggleTaskCompletion(String taskId)` [@lib/providers/task_model.dart#167-179]
**Returns**: `Future<void>`
**Mục đích**: Toggle trạng thái hoàn thành

```dart
await taskModel.toggleTaskCompletion(taskId);
```

**Flow**:
```
1. Call _databaseService.toggleTaskComplete()
2. Service tự động flip is_completed
3. Update task trong _tasks list
4. notifyListeners()
```

### 🔍 Getters & Filters [@lib/providers/task_model.dart#69-93]

#### `tasks`
**Returns**: `List<Task>` (unmodifiable)
**Mục đích**: Lấy tất cả tasks

#### `completedTasks`
**Returns**: `List<Task>`
**Mục đích**: Chỉ lấy tasks đã hoàn thành

```dart
final completed = taskModel.completedTasks;
```

#### `pendingTasks`
**Returns**: `List<Task>`
**Mục đích**: Chỉ lấy tasks chưa hoàn thành

#### `getTasksByCategory(TaskCategory category)`
**Returns**: `List<Task>`
**Mục đích**: Lọc tasks theo category

```dart
final workTasks = taskModel.getTasksByCategory(TaskCategory.work);
```

#### `getTasksByDate(DateTime date)`
**Returns**: `List<Task>`
**Mục đích**: Lấy tasks có deadline vào ngày cụ thể

```dart
final todayTasks = taskModel.getTasksByDate(DateTime.now());
```

### 🔄 Realtime Subscription

#### `_setupRealtimeSubscription()` [@lib/providers/task_model.dart#48-60]
**Mục đích**: Lắng nghe thay đổi realtime từ Supabase

```dart
_tasksSubscription = _databaseService.subscribeToTasks((updatedTasks) {
  _tasks.clear();
  _tasks.addAll(updatedTasks);
  notifyListeners();
});
```

**Khi có event**:
```
1. INSERT/UPDATE/DELETE event từ Supabase
2. Callback được gọi với updated tasks
3. Refresh _tasks list
4. UI tự động rebuild
```

### 🧹 Cleanup

#### `dispose()`
**Mục đích**: Hủy subscription khi Provider bị dispose

```dart
@override
void dispose() {
  _tasksSubscription?.unsubscribe();
  super.dispose();
}
```

---

## 3️⃣ CategoryModel (`category_model.dart`) [@lib/providers/category_model.dart#1-200]

### 🎯 Mục đích
Quản lý custom categories của user.

### 🔑 State Properties

| Property | Type | Description |
|----------|------|-------------|
| `_categories` | List<Map<String, dynamic>> | Danh sách categories |
| `_isLoading` | bool | Đang load? |

### 📡 Public Methods

#### `loadCategories()` [@lib/providers/category_model.dart#32-63]
**Mục đích**: Load categories từ Supabase

#### `createCategory(String name, String icon, String color)` [@lib/providers/category_model.dart#81-115]
**Mục đích**: Tạo category mới

#### `updateCategory(String id, ...)` [@lib/providers/category_model.dart#117-147]
**Mục đích**: Cập nhật category

#### `deleteCategory(String id)` [@lib/providers/category_model.dart#149-177]
**Mục đích**: Xóa category

---

## 4️⃣ FocusSessionModel (`focus_session_model.dart`) [@lib/providers/focus_session_model.dart#1-260]

### 🎯 Mục đích
Quản lý các phiên focus/pomodoro.

### 🔑 State Properties

| Property | Type | Description |
|----------|------|-------------|
| `_focusSessions` | List<FocusSession> | Danh sách sessions |
| `_currentSession` | FocusSession? | Session đang active |
| `_isLoading` | bool | Loading state |

### 📡 Public Methods

#### `startSession(Task? task, int duration)` [@lib/providers/focus_session_model.dart#71-141]
**Mục đích**: Bắt đầu phiên focus mới

```dart
await focusSessionModel.startSession(
  task,
  25, // minutes
);
```

#### `pauseSession()` [@lib/providers/focus_session_model.dart#143-163]
**Mục đích**: Tạm dừng session hiện tại

#### `resumeSession()` [@lib/providers/focus_session_model.dart#165-181]
**Mục đích**: Tiếp tục session đã pause

#### `completeSession()` [@lib/providers/focus_session_model.dart#183-214]
**Mục đích**: Hoàn thành session

#### `cancelSession()` [@lib/providers/focus_session_model.dart#216-239]
**Mục đích**: Hủy session

#### `loadFocusSessions()` [@lib/providers/focus_session_model.dart#47-69]
**Mục đích**: Load history

---

## 5️⃣ ThemeProvider (`theme_provider.dart`) [@lib/providers/theme_provider.dart#1-120]

### 🎯 Mục đích
Quản lý dark/light mode.

### 🔑 State Properties

| Property | Type | Description |
|----------|------|-------------|
| `_themeMode` | ThemeMode | Current theme |

### 📡 Public Methods

#### `toggleTheme()` [@lib/providers/theme_provider.dart#37-52]
**Mục đích**: Chuyển đổi theme

```dart
themeProvider.toggleTheme();
// light → dark → system → light
```

#### `setThemeMode(ThemeMode mode)` [@lib/providers/theme_provider.dart#54-68]
**Mục đích**: Set theme cụ thể

---

## 6️⃣ SettingsModel (`settings_model.dart`) [@lib/providers/settings_model.dart#1-180]

### 🎯 Mục đích
Quản lý các cài đặt ứng dụng.

### 🔑 State Properties

| Property | Type | Description |
|----------|------|-------------|
| `_language` | String | Ngôn ngữ hiện tại |
| `_notificationsEnabled` | bool | Bật thông báo? |
| `_soundEnabled` | bool | Bật âm thanh? |

---

## 7️⃣ GoogleSignInProvider (`google_signin_provider.dart`) [@lib/providers/google_signin_provider.dart#1-200]

### 🎯 Mục đích
Xử lý Google OAuth authentication.

### 📡 Public Methods

#### `signIn()` [@lib/providers/google_signin_provider.dart#24-90]
**Returns**: `Future<bool>`
**Mục đích**: Đăng nhập qua Google

```dart
final success = await googleProvider.signIn();
if (success) {
  // Update AuthModel
  // Navigate to home
}
```

**Flow**:
```
1. Call GoogleAuthService
2. Launch Google OAuth flow
3. Exchange token với Supabase
4. Update AuthModel state
```

---

## 8️⃣ GitHubSignInProvider (`github_signin_provider.dart`) [@lib/providers/github_signin_provider.dart#1-160]

### 🎯 Mục đích
Xử lý GitHub OAuth authentication.

### 📡 Public Methods

#### `signIn()` [@lib/providers/github_signin_provider.dart#24-110]
**Returns**: `Future<bool>`
**Mục đích**: Đăng nhập qua GitHub

---

## 🔄 Provider Lifecycle

```
App Start
  ↓
MultiProvider creates instances
  ↓
Providers call initialize()
  ↓
Load initial data
  ↓
Setup realtime subscriptions
  ↓
[App Running - listening to changes]
  ↓
User action triggers method
  ↓
Provider updates state
  ↓
notifyListeners()
  ↓
Consumer widgets rebuild
  ↓
UI updates
```

---

## 📊 Provider Communication Pattern

```
UI (Screen/Widget)
  ↓
  context.read<Provider>().method()
  ↓
Provider (Business Logic)
  ↓
Service (API/Database)
  ↓
Supabase Backend
  ↓
Response
  ↓
Provider updates state
  ↓
notifyListeners()
  ↓
Consumer<Provider> rebuilds
  ↓
UI reflects new state
```

---

## 💡 Best Practices

### 1. Sử dụng read() vs watch()

```dart
// ✅ Trong event handler - dùng read()
onPressed: () {
  context.read<TaskModel>().addTask(task);
}

// ✅ Trong build() - dùng watch() hoặc Consumer
final tasks = context.watch<TaskModel>().tasks;

// ❌ KHÔNG dùng watch() trong event handler
onPressed: () {
  context.watch<TaskModel>().addTask(task); // Wrong!
}
```

### 2. Consumer cho selective rebuild

```dart
// Chỉ rebuild widget con khi TaskModel thay đổi
Consumer<TaskModel>(
  builder: (context, taskModel, child) {
    return ListView.builder(
      itemCount: taskModel.tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(task: taskModel.tasks[index]);
      },
    );
  },
)
```

### 3. Selector cho optimization

```dart
// Chỉ rebuild khi completedTasks.length thay đổi
Selector<TaskModel, int>(
  selector: (context, taskModel) => taskModel.completedTasks.length,
  builder: (context, completedCount, child) {
    return Text('Completed: $completedCount');
  },
)
```

### 4. Error Handling

```dart
try {
  await taskModel.addTask(task);
  // Show success
} catch (e) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.toString()}')),
  );
}
```

### 5. Loading States

```dart
Consumer<TaskModel>(
  builder: (context, taskModel, child) {
    if (taskModel.isLoading) {
      return CircularProgressIndicator();
    }
    return TaskList(tasks: taskModel.tasks);
  },
)
```

---

## 🎯 Khi nào dùng Provider nào?

| Scenario | Provider |
|----------|----------|
| Đăng nhập/Đăng xuất | `AuthModel` |
| CRUD tasks | `TaskModel` |
| Quản lý categories | `CategoryModel` |
| Focus/Pomodoro | `FocusSessionModel` |
| Dark/Light mode | `ThemeProvider` |
| App settings | `SettingsModel` |
| Google login | `GoogleSignInProvider` |
| GitHub login | `GitHubSignInProvider` |

---

## 🔌 Dependencies Injection

Trong `app.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthModel()),
    ChangeNotifierProvider(create: (_) => TaskModel()..initialize()),
    ChangeNotifierProvider(create: (_) => CategoryModel()..loadCategories()),
    ChangeNotifierProvider(create: (_) => FocusSessionModel()..loadFocusSessions()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => SettingsModel()),
    ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
    ChangeNotifierProvider(create: (_) => GitHubSignInProvider()),
  ],
  child: MyApp(),
)
```

---

✅ **Hoàn thành tài liệu Providers!**
