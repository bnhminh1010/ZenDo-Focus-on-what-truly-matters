# TÀI LIỆU CHI TIẾT: MODELS

## 📁 Thư mục: `lib/models/`

### Tổng quan
Models định nghĩa cấu trúc dữ liệu của ứng dụng. Mỗi model đại diện cho một entity trong database và cung cấp methods để serialize/deserialize dữ liệu.

---

## 1️⃣ Task Model (`task.dart`) [@lib/models/task.dart#1-380]

### 🎯 Mục đích
Model chính của ứng dụng, đại diện cho một công việc/nhiệm vụ cần hoàn thành.

### 📊 Enums

#### TaskCategory
```dart
enum TaskCategory {
  work('Công việc'),
  personal('Cá nhân'),
  learning('Học tập'),
  health('Sức khỏe'),
  finance('Tài chính'),
  social('Xã hội'),
  other('Khác')
}
```

#### TaskPriority
```dart
enum TaskPriority {
  low('Thấp'),           // priorityOrder = 1
  medium('Trung bình'),  // priorityOrder = 2
  high('Cao'),           // priorityOrder = 3
  urgent('Khẩn cấp')     // priorityOrder = 4
}
```

### 🔑 Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | UUID của task |
| `title` | String | Tiêu đề task |
| `description` | String? | Mô tả chi tiết |
| `category` | TaskCategory | Danh mục |
| `priority` | TaskPriority | Mức độ ưu tiên |
| `createdAt` | DateTime | Thời gian tạo |
| `dueDate` | DateTime? | Hạn hoàn thành |
| `isCompleted` | bool | Trạng thái hoàn thành |
| `completedAt` | DateTime? | Thời gian hoàn thành |
| `tags` | List<String> | Tags |
| `notes` | String? | Ghi chú |
| `estimatedMinutes` | int | Thời gian ước tính |
| `actualMinutes` | int | Thời gian thực tế |
| `imageUrl` | String? | URL hình ảnh đính kèm |
| `parentTaskId` | String? | ID của task cha (cho subtask) |
| `subtaskIds` | List<String> | Danh sách ID subtasks |
| `focusTimeMinutes` | int | Thời gian focus mặc định (25 phút) |

### 📡 Methods Chính

#### `copyWith({...})` [@lib/models/task.dart#119-160]
**Mục đích**: Tạo bản copy với một số thuộc tính thay đổi (immutable pattern)
```dart
final updatedTask = task.copyWith(
  isCompleted: true,
  completedAt: DateTime.now(),
);
```

#### `toMap()` / `fromMap(Map)` [@lib/models/task.dart#162-220]
**Mục đích**: Serialize/deserialize cho local storage (SQLite)
```dart
final map = task.toMap();
final task = Task.fromMap(map);
```

#### `toSupabaseMap()` / `fromSupabaseMap(Map)` [@lib/models/task.dart#222-279]
**Mục đích**: Serialize/deserialize cho Supabase
```dart
// Supabase sử dụng snake_case
{
  'id': id,
  'title': title,
  'created_at': createdAt.toIso8601String(),
  'is_completed': isCompleted,
  // ...
}
```

**Khác biệt chính**:
- Map local: `createdAt` (timestamp milliseconds)
- Map Supabase: `created_at` (ISO8601 string)

### 🔍 Getters Tiện ích

#### `isOverdue` [@lib/models/task.dart#281-285]
**Returns**: `bool`
**Logic**: `dueDate != null && !isCompleted && DateTime.now().isAfter(dueDate)`

#### `isDueToday` [@lib/models/task.dart#288-294]
**Returns**: `bool`
**Logic**: Kiểm tra dueDate có cùng ngày với hôm nay

#### `isDueThisWeek` [@lib/models/task.dart#297-303]
**Returns**: `bool`
**Logic**: Kiểm tra dueDate trong tuần này

#### `daysUntilDue` [@lib/models/task.dart#306-310]
**Returns**: `int?`
**Logic**: Số ngày còn lại đến hạn

#### `isSubtask` [@lib/models/task.dart#347-351]
**Returns**: `bool`
**Logic**: `parentTaskId != null`

#### `hasSubtasks` [@lib/models/task.dart#353-355]
**Returns**: `bool`
**Logic**: `subtaskIds.isNotEmpty`

#### `getSubtaskProgress` [@lib/models/task.dart#356-363]
**Returns**: `double`
**Logic**: Tính toán tiến độ hoàn thành của subtasks

### 🎨 Color Getters

#### `priorityColorHex` [@lib/models/task.dart#313-325]
```dart
TaskPriority.low → '#4CAF50' (Green)
TaskPriority.medium → '#FF9800' (Orange)
TaskPriority.high → '#F44336' (Red)
TaskPriority.urgent → '#9C27B0' (Purple)
```

#### `categoryColorHex` [@lib/models/task.dart#328-344]
```dart
TaskCategory.work → '#2196F3' (Blue)
TaskCategory.personal → '#4CAF50' (Green)
TaskCategory.learning → '#FF9800' (Orange)
// ...
```

---

## 2️⃣ Category Model (`category.dart`) [@lib/models/category.dart#1-180]

### 🎯 Mục đích
Quản lý danh mục task tùy chỉnh của người dùng.

### 🔑 Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | UUID của category |
| `userId` | String | ID người dùng sở hữu |
| `name` | String | Tên danh mục |
| `description` | String? | Mô tả |
| `icon` | String | Emoji icon (📝, 💼, 📚...) |
| `color` | String | Hex color (#3B82F6) |
| `isDefault` | bool | Category mặc định? |
| `sortOrder` | int | Thứ tự hiển thị |
| `isArchived` | bool | Đã ẩn? |
| `createdAt` | DateTime | Thời gian tạo |
| `updatedAt` | DateTime | Thời gian cập nhật |

### 📡 Methods

#### `fromJson(Map)` / `toJson()` [@lib/models/category.dart#36-72]
**Mục đích**: Serialize/deserialize với Supabase
```dart
// Supabase format
{
  'id': id,
  'user_id': userId,
  'name': name,
  'icon': icon,
  'color': color,
  'is_default': isDefault,
  'sort_order': sortOrder,
  'created_at': createdAt.toIso8601String(),
  // ...
}
```

### 📋 DefaultCategories [@lib/models/category.dart#118-178]

**Class**: `DefaultCategories`
**Mục đích**: Danh mục mặc định cho user mới

```dart
static const List<Map<String, dynamic>> defaults = [
  {
    'name': 'Công việc',
    'icon': '💼',
    'color': '#3B82F6',
    'is_default': true,
    'sort_order': 1,
  },
  {
    'name': 'Cá nhân',
    'icon': '👤',
    'color': '#10B981',
    'is_default': true,
    'sort_order': 2,
  },
  // ... 7 categories tổng cộng
];
```

---

## 3️⃣ FocusSession Model (`focus_session.dart`) [@lib/models/focus_session.dart#1-220]

### 🎯 Mục đích
Theo dõi các phiên làm việc tập trung (Pomodoro sessions).

### 📊 Enum: FocusSessionStatus [@lib/models/focus_session.dart#188-217]

```dart
enum FocusSessionStatus {
  active,      // Đang hoạt động
  paused,      // Tạm dừng
  completed,   // Hoàn thành
  cancelled    // Đã hủy
}
```

### 🔑 Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String? | UUID của session |
| `userId` | String | ID người dùng |
| `taskId` | String? | ID task đang focus |
| `title` | String? | Tiêu đề session |
| `plannedDurationMinutes` | int | Thời lượng dự kiến (mặc định 25) |
| `actualDurationMinutes` | int | Thời lượng thực tế |
| `breakDurationMinutes` | int | Thời lượng nghỉ (mặc định 5) |
| `startedAt` | DateTime | Thời gian bắt đầu |
| `endedAt` | DateTime? | Thời gian kết thúc |
| `pausedAt` | DateTime? | Thời gian tạm dừng |
| `totalPauseDurationMinutes` | int | Tổng thời gian pause |
| `status` | FocusSessionStatus | Trạng thái hiện tại |
| `sessionType` | String | Loại session (pomodoro, pyramid...) |
| `productivityRating` | int? | Đánh giá năng suất (1-5) |
| `distractionCount` | int | Số lần xao nhãng |
| `notes` | String? | Ghi chú |
| `backgroundSound` | String? | Âm thanh nền |
| `createdAt` | DateTime | Thời gian tạo |
| `updatedAt` | DateTime | Thời gian cập nhật |

### 📡 Methods

#### `fromSupabaseMap(Map)` / `toSupabaseMap()` [@lib/models/focus_session.dart#52-107]
**Mục đích**: Serialize/deserialize với Supabase
```dart
// Supabase format sử dụng snake_case
{
  'user_id': userId,
  'task_id': taskId,
  'planned_duration_minutes': plannedDurationMinutes,
  'actual_duration_minutes': actualDurationMinutes,
  'started_at': startedAt.toIso8601String(),
  'status': status.name,
  // ...
}
```

#### `copyWith({...})`
**Mục đích**: Tạo instance mới với thay đổi
```dart
final pausedSession = session.copyWith(
  status: FocusSessionStatus.paused,
  pausedAt: DateTime.now(),
);
```

### 📈 State Transitions

```
CREATE session (status: active)
  ↓
PAUSE → status: paused, pausedAt: now
  ↓
RESUME → status: active, pausedAt: null
  ↓
COMPLETE → status: completed, endedAt: now, actualDurationMinutes: calculated
  or
CANCEL → status: cancelled, endedAt: now
```

---

## 4️⃣ User Model (`user.dart`) [@lib/models/user.dart#1-200]

### 🎯 Mục đích
Đại diện cho thông tin người dùng.

### 🔑 Properties (Dự kiến)

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | UUID từ Supabase Auth |
| `email` | String | Email |
| `fullName` | String | Họ tên |
| `avatarUrl` | String? | URL avatar |
| `createdAt` | DateTime | Ngày đăng ký |
| `preferences` | Map? | Tùy chọn cá nhân |

---

## 5️⃣ AIMessage Model (`ai_message.dart`) [@lib/models/ai_message.dart#1-200]

### 🎯 Mục đích
Quản lý tin nhắn trong AI chat với Gemini.

### 🔑 Properties (Dự kiến)

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | UUID của message |
| `role` | String | 'user' hoặc 'assistant' |
| `content` | String | Nội dung tin nhắn |
| `timestamp` | DateTime | Thời gian gửi |
| `isError` | bool | Có phải error message? |

---

## 6️⃣ Subtask Model (`subtask.dart`) [@lib/models/subtask.dart#1-200]

### 🎯 Mục đích
Quản lý subtasks (công việc con) của một task.

### 🔑 Properties (Dự kiến)

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | UUID |
| `parentTaskId` | String | ID của task cha |
| `title` | String | Tiêu đề |
| `isCompleted` | bool | Hoàn thành? |
| `sortOrder` | int | Thứ tự |

---

## 7️⃣ Reminder Model (`reminder.dart`) [@lib/models/reminder.dart#1-200]

### 🎯 Mục đích
Quản lý nhắc nhở cho tasks.

### 🔑 Properties (Dự kiến)

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | UUID |
| `taskId` | String | Task cần nhắc |
| `reminderTime` | DateTime | Thời gian nhắc |
| `type` | String | Loại nhắc nhở |
| `isActive` | bool | Còn active? |

---

## 8️⃣ Tag Model (`tag.dart`) [@lib/models/tag.dart#1-200]

### 🎯 Mục đích
Quản lý tags cho tasks.

### 🔑 Properties (Dự kiến)

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | UUID |
| `name` | String | Tên tag |
| `color` | String | Màu sắc |
| `userId` | String | User sở hữu |

---

## 🔄 Data Flow của Models

```
UI Input
  ↓
Create Model instance
  ↓
toSupabaseMap()
  ↓
SupabaseDatabaseService
  ↓
Supabase Backend (INSERT/UPDATE)
  ↓
Realtime event
  ↓
fromSupabaseMap()
  ↓
Update Provider state
  ↓
notifyListeners()
  ↓
UI rebuild
```

---

## 💡 Patterns Sử Dụng

### 1. Immutability
**Tất cả fields đều là `final`**
- Không thể modify trực tiếp
- Sử dụng `copyWith()` để tạo instance mới

```dart
// ❌ Không thể làm
task.title = "New title";

// ✅ Đúng cách
final updatedTask = task.copyWith(title: "New title");
```

### 2. Factory Constructors
**Để deserialize data**
```dart
factory Task.fromSupabaseMap(Map<String, dynamic> map) {
  return Task(
    id: map['id'],
    title: map['title'],
    // ... parse và validate
  );
}
```

### 3. Null Safety
**Handle null values một cách an toàn**
```dart
description: map['description'] as String?,  // Nullable
priority: TaskPriority.values.firstWhere(
  (e) => e.name == map['priority'],
  orElse: () => TaskPriority.medium,  // Default value
),
```

### 4. Enum Extensions
**Thêm functionality cho enums**
```dart
extension FocusSessionStatusExtension on FocusSessionStatus {
  String get displayName {
    switch (this) {
      case FocusSessionStatus.active:
        return 'Đang hoạt động';
      // ...
    }
  }
}
```

---

## 🎓 Best Practices

### 1. Validation trong Models
```dart
// Validate trong constructor hoặc factory
if (title.isEmpty) {
  throw ArgumentError('Title cannot be empty');
}
```

### 2. Computed Properties
```dart
// Thay vì store, compute khi cần
bool get isOverdue {
  if (dueDate == null || isCompleted) return false;
  return DateTime.now().isAfter(dueDate!);
}
```

### 3. toString() Override
```dart
@override
String toString() {
  return 'Task(id: $id, title: $title, isCompleted: $isCompleted)';
}
```

### 4. Equality Operators
```dart
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;
  return other is Task && other.id == id;
}

@override
int get hashCode => id.hashCode;
```

---

## 🔍 Khi nào dùng Model nào?

### Task
- Quản lý công việc chính
- CRUD operations
- Display trong lists/grids

### Category
- Phân loại tasks
- Custom categories
- Statistics by category

### FocusSession
- Track thời gian focus
- Pomodoro timer
- Productivity analytics

### AIMessage
- Chat với Gemini AI
- Message history
- Conversation context

---

✅ **Hoàn thành tài liệu Models!**
