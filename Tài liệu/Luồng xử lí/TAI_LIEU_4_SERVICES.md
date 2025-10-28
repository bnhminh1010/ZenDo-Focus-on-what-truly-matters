# TÀI LIỆU CHI TIẾT: SERVICES

## 📁 Thư mục: `lib/services/`

### Tổng quan
Services là lớp trung gian giữa Providers và Backend. Xử lý API calls, database operations, và external integrations.

---

## 1️⃣ SupabaseDatabaseService (`supabase_database_service.dart`) [@lib/services/supabase_database_service.dart#1-570]

### 🎯 Mục đích
Service trung tâm để thao tác với Supabase database. Xử lý CRUD operations cho tasks, categories, focus sessions.

### 🔑 Private Properties

```dart
final SupabaseClient _supabase = Supabase.instance.client;
String? get _currentUserId => _supabase.auth.currentUser?.id;
bool get isUserAuthenticated => _currentUserId != null;
```

### 📊 TASKS OPERATIONS

#### `getTasks()` [@lib/services/supabase_database_service.dart#26-45]
**Returns**: `Future<List<Task>>`
**Mục đích**: Lấy tất cả tasks của user

```dart
final tasks = await service.getTasks();
```

**SQL Query**:
```sql
SELECT * FROM tasks 
WHERE user_id = $currentUserId 
ORDER BY created_at DESC
```

#### `getTasksByCategory(String categoryId)` [@lib/services/supabase_database_service.dart#48-68]
**Returns**: `Future<List<Task>>`
**Mục đích**: Lấy tasks theo category

**SQL Query**:
```sql
SELECT * FROM tasks 
WHERE user_id = $currentUserId AND category_id = $categoryId
ORDER BY created_at DESC
```

#### `createTask(Task task)` [@lib/services/supabase_database_service.dart#71-107]
**Returns**: `Future<Task?>`
**Mục đích**: Tạo task mới

```dart
final createdTask = await service.createTask(task);
```

**Flow**:
```
1. Validate user authentication
2. Convert task.toSupabaseMap()
3. Add user_id, created_at, updated_at
4. INSERT vào database
5. Return Task object mới
```

**Timeout**: 15 seconds

#### `updateTask(String taskId, Task updatedTask)` [@lib/services/supabase_database_service.dart#110-133]
**Returns**: `Future<Task?>`
**Mục đích**: Cập nhật task

**SQL Query**:
```sql
UPDATE tasks 
SET title=$title, description=$desc, ..., updated_at=NOW()
WHERE id=$taskId AND user_id=$currentUserId
RETURNING *
```

#### `deleteTask(String taskId)` [@lib/services/supabase_database_service.dart#136-154]
**Returns**: `Future<bool>`
**Mục đích**: Xóa task

**SQL Query**:
```sql
DELETE FROM tasks 
WHERE id=$taskId AND user_id=$currentUserId
```

#### `toggleTaskComplete(String taskId)` [@lib/services/supabase_database_service.dart#157-193]
**Returns**: `Future<Task?>`
**Mục đích**: Toggle trạng thái hoàn thành

**Flow**:
```
1. SELECT is_completed FROM tasks WHERE id=$taskId
2. Flip boolean value
3. UPDATE is_completed, updated_at
4. RETURN updated task
```

---

### 🎯 FOCUS SESSIONS OPERATIONS

#### `createFocusSession(FocusSession session)` [@lib/services/supabase_database_service.dart#198-239]
**Returns**: `Future<FocusSession?>`
**Mục đích**: Tạo focus session mới

```dart
final session = await service.createFocusSession(newSession);
```

**Flow**:
```
1. Convert session.toSupabaseMap()
2. Add user_id, created_at, updated_at
3. INSERT vào focus_sessions table
4. Return FocusSession object
```

#### `updateFocusSession(String sessionId, FocusSession updatedSession)` [@lib/services/supabase_database_service.dart#242-268]
**Returns**: `Future<FocusSession?>`
**Mục đích**: Cập nhật session (status, endedAt, etc.)

#### `getFocusSessions()` [@lib/services/supabase_database_service.dart#271-290]
**Returns**: `Future<List<FocusSession>>`
**Mục đích**: Lấy tất cả focus sessions

**SQL Query**:
```sql
SELECT * FROM focus_sessions 
WHERE user_id = $currentUserId 
ORDER BY started_at DESC
```

#### `getFocusSessionsByTask(String taskId)` [@lib/services/supabase_database_service.dart#293-313]
**Returns**: `Future<List<FocusSession>>`
**Mục đích**: Lấy sessions của một task cụ thể

#### `deleteFocusSession(String sessionId)` [@lib/services/supabase_database_service.dart#316-333]
**Returns**: `Future<bool>`
**Mục đích**: Xóa session

#### `getFocusSessionsStatistics()` [@lib/services/supabase_database_service.dart#337-382]
**Returns**: `Future<Map<String, dynamic>>`
**Mục đích**: Tính thống kê focus sessions

**Returns**:
```dart
{
  'total_sessions': 150,
  'completed_sessions': 120,
  'total_focus_minutes': 3000,
  'average_productivity_rating': 4.2,
  'completion_rate': 80.0
}
```

---

### 📂 CATEGORIES OPERATIONS

#### `getCategories()` [@lib/services/supabase_database_service.dart#385-404]
**Returns**: `Future<List<Map<String, dynamic>>>`
**Mục đích**: Lấy tất cả categories của user

#### `createCategory({required String name, required String icon, required String color})` [@lib/services/supabase_database_service.dart#407-435]
**Returns**: `Future<Map<String, dynamic>?>`
**Mục đích**: Tạo category mới

```dart
final category = await service.createCategory(
  name: 'Work',
  icon: '💼',
  color: '#3B82F6',
);
```

#### `updateCategory(String categoryId, { ... })` [@lib/services/supabase_database_service.dart#438-463]
**Returns**: `Future<Map<String, dynamic>?>`
**Mục đích**: Cập nhật category

#### `deleteCategory(String categoryId)` [@lib/services/supabase_database_service.dart#466-485]
**Returns**: `Future<bool>`
**Mục đích**: Xóa category

**Note**: Tasks có category_id này sẽ set về NULL (ON DELETE SET NULL)

---

### 🔄 REALTIME SUBSCRIPTIONS

#### `subscribeToTasks(Function(List<Task>) onTasksChanged)` [@lib/services/supabase_database_service.dart#488-515]
**Returns**: `RealtimeChannel`
**Mục đích**: Subscribe realtime updates cho tasks

```dart
final subscription = service.subscribeToTasks((updatedTasks) {
  // Handle updated tasks
  _tasks.clear();
  _tasks.addAll(updatedTasks);
  notifyListeners();
});
```

**Events handled**:
- `INSERT`: Task mới được tạo
- `UPDATE`: Task được cập nhật
- `DELETE`: Task bị xóa

**Filter**: Chỉ nhận events với `user_id = currentUserId`

#### `subscribeToCategories(Function(List<Map<String, dynamic>>) onCategoriesChanged)` [@lib/services/supabase_database_service.dart#517-544]
**Returns**: `RealtimeChannel`
**Mục đích**: Subscribe realtime updates cho categories

---

### 📈 STATISTICS

#### `getTasksStatistics()` [@lib/services/supabase_database_service.dart#547-567]
**Returns**: `Future<Map<String, int>>`
**Mục đích**: Thống kê tổng quan về tasks

**Returns**:
```dart
{
  'total': 50,
  'completed': 30,
  'pending': 20
}
```

---

## 2️⃣ SupabaseAuthService (`supabase_auth_service.dart`)

### 🎯 Mục đích
Quản lý authentication với Supabase Auth.

### 🔑 Properties

```dart
final SupabaseClient _supabase = Supabase.instance.client;
bool _isLoading = false;

User? get currentUser => _supabase.auth.currentUser;
String? get userEmail => currentUser?.email;
String? get userId => currentUser?.id;
```

### 📡 Methods

#### `initialize()`
**Mục đích**: Setup auth state listener

```dart
_supabase.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  final session = data.session;
  
  if (event == AuthChangeEvent.signedIn) {
    debugPrint('User signed in: ${session?.user.email}');
  } else if (event == AuthChangeEvent.signedOut) {
    debugPrint('User signed out');
  }
  
  notifyListeners();
});
```

#### `signIn(String email, String password)`
**Returns**: `Future<bool>`
**Mục đích**: Đăng nhập

```dart
final success = await authService.signIn(email, password);
```

**Flow**:
```
1. Trim & validate email format
2. Call Supabase.auth.signInWithPassword()
3. Return true nếu có user
4. Handle AuthException
```

#### `signUp(String name, String email, String password)`
**Returns**: `Future<bool>`
**Mục đích**: Đăng ký tài khoản mới

```dart
final success = await authService.signUp(name, email, password);
```

**Flow**:
```
1. Validate email
2. Call Supabase.auth.signUp() với metadata
3. Database trigger tự động tạo profile
4. Return true nếu thành công
```

**User Metadata**:
```dart
data: {'full_name': name}
```

#### `signOut()`
**Returns**: `Future<void>`
**Mục đích**: Đăng xuất

```dart
await authService.signOut();
```

#### `updateProfile(String name, String email)`
**Returns**: `Future<bool>`
**Mục đích**: Cập nhật user metadata

```dart
final success = await authService.updateProfile(name, email);
```

#### `updateProfileWithAvatar(String name, String email, String? avatarUrl)`
**Returns**: `Future<bool>`
**Mục đích**: Cập nhật profile kèm avatar

**Flow**:
```
1. Update auth.user metadata
2. Upsert vào profiles table
3. Return success
```

#### `resetPassword(String email)`
**Returns**: `Future<bool>`
**Mục đích**: Gửi email reset password

#### `updatePassword(String currentPassword, String newPassword)`
**Returns**: `Future<bool>`
**Mục đích**: Đổi mật khẩu

---

## 3️⃣ ProfileService (`profile_service.dart`)

### 🎯 Mục đích
Quản lý user profile data.

### 📡 Methods

#### `getCurrentUserAvatarUrl()`
**Returns**: `Future<String?>`
**Mục đích**: Lấy avatar URL của user hiện tại

```dart
final avatarUrl = await profileService.getCurrentUserAvatarUrl();
```

**SQL Query**:
```sql
SELECT avatar_url FROM profiles 
WHERE id = $currentUserId
```

---

## 4️⃣ AvatarStorageService (`avatar_storage_service.dart`)

### 🎯 Mục đích
Upload và quản lý avatar images trong Supabase Storage.

### 📡 Methods

#### `uploadAvatar(File imageFile, String userId)`
**Returns**: `Future<String?>`
**Mục đích**: Upload avatar và return public URL

```dart
final avatarUrl = await service.uploadAvatar(imageFile, userId);
```

**Flow**:
```
1. Compress image
2. Generate unique filename: avatars/$userId/$timestamp.jpg
3. Upload to Supabase Storage bucket 'avatars'
4. Get public URL
5. Return URL
```

---

## 5️⃣ GeminiAIService (`gemini_ai_service.dart`)

### 🎯 Mục đích
Tích hợp Google Gemini AI cho chat assistant.

### 📡 Methods

#### `sendMessage(String message, List<AIMessage> history)`
**Returns**: `Future<String>`
**Mục đích**: Gửi message và nhận response từ AI

```dart
final response = await geminiService.sendMessage(
  'Gợi ý task cho tôi hôm nay',
  chatHistory,
);
```

**Flow**:
```
1. Build conversation context từ history
2. Call Gemini API
3. Parse response
4. Return AI reply
```

---

## 6️⃣ GoogleAuthService (`google_auth_service.dart`)

### 🎯 Mục đích
Xử lý Google OAuth flow.

### 📡 Methods

#### `signInWithGoogle()`
**Returns**: `Future<User?>`
**Mục đích**: Đăng nhập qua Google

**Flow**:
```
1. Launch Google Sign-In
2. Get Google ID token
3. Exchange với Supabase
4. Return Supabase user
```

---

## 7️⃣ GitHubAuthService (`github_auth_service.dart`)

### 🎯 Mục đích
Xử lý GitHub OAuth flow.

### 📡 Methods

#### `signInWithGitHub()`
**Returns**: `Future<bool>`
**Mục đích**: Đăng nhập qua GitHub

---

## 8️⃣ ImageStorageService (`image_storage_service.dart`)

### 🎯 Mục đích
Upload hình ảnh đính kèm cho tasks.

### 📡 Methods

#### `uploadTaskImage(File imageFile, String taskId)`
**Returns**: `Future<String?>`
**Mục đích**: Upload image và return URL

**Storage path**: `task_images/$userId/$taskId/$filename`

---

## 🔄 Service Layer Architecture

```
Provider Layer
  ↓
  calls
  ↓
Service Layer
  ↓
  - Data transformation
  - Error handling
  - Retry logic
  - Timeout management
  ↓
Supabase Client
  ↓
Supabase Backend
```

---

## ⚡ Error Handling Pattern

```dart
try {
  final result = await _supabase.from('tasks').insert(data);
  return Task.fromSupabaseMap(result);
} on TimeoutException catch (e) {
  debugPrint('Timeout: $e');
  throw Exception('Connection timeout');
} on PostgrestException catch (e) {
  debugPrint('Database error: $e');
  throw Exception('Database error: ${e.message}');
} catch (e) {
  debugPrint('Unknown error: $e');
  rethrow;
}
```

---

## 🎯 Khi nào dùng Service nào?

| Scenario | Service |
|----------|---------|
| CRUD tasks | `SupabaseDatabaseService` |
| CRUD categories | `SupabaseDatabaseService` |
| Focus sessions | `SupabaseDatabaseService` |
| Realtime sync | `SupabaseDatabaseService` |
| Login/Signup | `SupabaseAuthService` |
| Profile data | `ProfileService` |
| Avatar upload | `AvatarStorageService` |
| AI chat | `GeminiAIService` |
| Google login | `GoogleAuthService` |
| GitHub login | `GitHubAuthService` |
| Task images | `ImageStorageService` |

---

## 💡 Best Practices

### 1. Always validate authentication
```dart
if (!isUserAuthenticated) {
  throw Exception('User not authenticated');
}
```

### 2. Add timeouts
```dart
await operation().timeout(
  Duration(seconds: 15),
  onTimeout: () => throw Exception('Timeout'),
);
```

### 3. Handle specific exceptions
```dart
try {
  // operation
} on TimeoutException {
  // Handle timeout
} on PostgrestException {
  // Handle database error
} on AuthException {
  // Handle auth error
} catch (e) {
  // Handle unknown error
}
```

### 4. Log operations
```dart
debugPrint('Creating task: ${task.title}');
final result = await createTask(task);
debugPrint('Task created: ${result.id}');
```

### 5. Return null on soft failures
```dart
Future<Task?> getTask(String id) async {
  try {
    return await _supabase.from('tasks').select().eq('id', id).single();
  } catch (e) {
    debugPrint('Error getting task: $e');
    return null; // Soft failure
  }
}
```

---

✅ **Hoàn thành tài liệu Services!**
