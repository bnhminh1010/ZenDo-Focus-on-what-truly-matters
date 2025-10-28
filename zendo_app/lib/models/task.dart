/*
 * Tên: models/task.dart
 * Tác dụng: Định nghĩa Task chính với danh mục, mức ưu tiên, trạng thái hoàn thành, hạn, thời gian ước tính và các phương thức chuyển đổi Map/Supabase.
 * Khi nào dùng: Khi tạo/hiển thị/chỉnh sửa/lưu trữ Task và đồng bộ với Supabase; hỗ trợ sắp xếp/lọc theo category/priority/trạng thái.
 */
import 'package:flutter/material.dart';

/// TaskCategory Enum
/// Tác dụng: Định nghĩa các loại danh mục công việc có thể có trong ứng dụng
/// Sử dụng khi: Cần phân loại task theo các lĩnh vực khác nhau như công việc, cá nhân, học tập
enum TaskCategory {
  work('Công việc'),
  personal('Cá nhân'),
  learning('Học tập'),
  health('Sức khỏe'),
  finance('Tài chính'),
  social('Xã hội'),
  other('Khác');

  const TaskCategory(this.displayName);
  final String displayName;
}

/// TaskPriority Enum
/// Tác dụng: Định nghĩa các mức độ ưu tiên của task từ thấp đến khẩn cấp
/// Sử dụng khi: Cần sắp xếp và ưu tiên các task theo độ quan trọng
enum TaskPriority {
  low('Thấp'),
  medium('Trung bình'),
  high('Cao'),
  urgent('Khẩn cấp');

  const TaskPriority(this.displayName);
  final String displayName;

  /// priorityOrder getter
  /// Tác dụng: Trả về số thứ tự ưu tiên để so sánh và sắp xếp
  /// Sử dụng khi: Cần sắp xếp danh sách task theo độ ưu tiên
  int get priorityOrder {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
      case TaskPriority.urgent:
        return 4;
    }
  }

  /// color getter (Deprecated)
  /// Tác dụng: Trả về màu sắc tương ứng với mức độ ưu tiên
  /// Sử dụng khi: Hiển thị màu sắc cho priority (nên dùng theme colors thay thế)
  @Deprecated('Use theme colors instead')
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.deepPurple;
    }
  }

  /// compareTo method
  /// Tác dụng: So sánh hai priority để sắp xếp
  /// Sử dụng khi: Cần sort danh sách task theo độ ưu tiên
  int compareTo(TaskPriority other) {
    return priorityOrder.compareTo(other.priorityOrder);
  }
}

/// Task Class
/// Tác dụng: Model chính định nghĩa cấu trúc dữ liệu của một công việc/nhiệm vụ
/// Sử dụng khi: Tạo, lưu trữ, và quản lý thông tin của các task trong ứng dụng
class Task {
  /// UUID của task (khóa chính đồng bộ Supabase/local DB).
  final String id;

  /// Tiêu đề ngắn gọn hiển thị chính trên UI.
  final String title;

  /// Mô tả chi tiết nội dung công việc (nullable).
  final String? description;

  /// Danh mục logic giúp phân loại và lọc task.
  final TaskCategory category;

  /// Mức độ ưu tiên để sắp xếp, cảnh báo.
  final TaskPriority priority;

  /// Thời điểm tạo task, phục vụ sorting/audit.
  final DateTime createdAt;

  /// Deadline dự kiến hoàn thành (nullable nếu không đặt hạn).
  final DateTime? dueDate;

  /// Trạng thái hoàn thành hiện tại.
  final bool isCompleted;

  /// Thời điểm đánh dấu hoàn thành (nullable).
  final DateTime? completedAt;

  /// Danh sách tag text tự do để tìm kiếm/nhóm nhanh.
  final List<String> tags;

  /// Ghi chú phụ (link, checklist...) hiển thị trong chi tiết.
  final String? notes;

  /// Thời gian ước lượng thực hiện (phút) do người dùng nhập.
  final int estimatedMinutes;

  /// Thời gian thực tế đã log (phút) từ focus sessions.
  final int actualMinutes;

  /// Đường dẫn ảnh minh hoạ lưu trên Supabase Storage.
  final String? imageUrl;

  /// ID task cha nếu là subtask (hierarchy).
  final String? parentTaskId;

  /// Danh sách ID subtasks con (dùng để load nhanh trạng thái).
  final List<String> subtaskIds;

  /// Thời gian focus mặc định mỗi phiên (phút) cho Pomodoro.
  final int focusTimeMinutes;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.tags = const [],
    this.notes,
    this.estimatedMinutes = 0,
    this.actualMinutes = 0,
    this.imageUrl,
    this.parentTaskId,
    this.subtaskIds = const [],
    this.focusTimeMinutes = 25,
  });

  /// copyWith method
  /// Tác dụng: Tạo bản copy của Task với một số thuộc tính được thay đổi
  /// Sử dụng khi: Cần cập nhật task mà không thay đổi object gốc (immutable pattern)
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? tags,
    String? notes,
    int? estimatedMinutes,
    int? actualMinutes,
    String? imageUrl,
    String? parentTaskId,
    List<String>? subtaskIds,
    int? focusTimeMinutes,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      subtaskIds: subtaskIds ?? this.subtaskIds,
      focusTimeMinutes: focusTimeMinutes ?? this.focusTimeMinutes,
    );
  }

  /// toMap method
  /// Tác dụng: Chuyển đổi Task object thành Map để lưu trữ vào database
  /// Sử dụng khi: Cần serialize task để lưu vào Supabase hoặc local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'tags': tags,
      'notes': notes,
      'estimatedMinutes': estimatedMinutes,
      'actualMinutes': actualMinutes,
      'imageUrl': imageUrl, // Thêm imageUrl vào toMap
      'parentTaskId': parentTaskId, // Thêm parentTaskId
      'subtaskIds': subtaskIds, // Thêm subtaskIds
      'focusTimeMinutes': focusTimeMinutes, // Thêm focusTimeMinutes
    };
  }

  /// Tạo Task từ Map (SQLite format)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.other,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'],
      estimatedMinutes: map['estimatedMinutes'] ?? 0,
      actualMinutes: map['actualMinutes'] ?? 0,
      imageUrl: map['imageUrl'], // Thêm imageUrl vào fromMap
      parentTaskId: map['parentTaskId'], // Thêm parentTaskId
      subtaskIds: List<String>.from(map['subtaskIds'] ?? []), // Thêm subtaskIds
      focusTimeMinutes:
          map['focusTimeMinutes'] ??
          25, // Thêm focusTimeMinutes với mặc định 25
    );
  }

  /// Chuyển đổi Task thành Map cho Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'tags': tags,
      'notes': notes,
      'estimated_minutes': estimatedMinutes,
      'actual_minutes': actualMinutes,
      'image_url': imageUrl, // Thêm imageUrl vào toSupabaseMap
      'parent_task_id': parentTaskId, // Thêm parent_task_id
      'focus_time_minutes': focusTimeMinutes, // Thêm focus_time_minutes
      // subtaskIds sẽ được quản lý riêng trong bảng subtasks
      // user_id và category_id sẽ được thêm trong service
    };
  }

  /// Tạo Task từ Supabase Map
  factory Task.fromSupabaseMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.other,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      isCompleted: map['is_completed'] ?? false,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'],
      estimatedMinutes: map['estimated_minutes'] ?? 0,
      actualMinutes: map['actual_minutes'] ?? 0,
      imageUrl: map['image_url'], // Thêm imageUrl vào fromSupabaseMap
      parentTaskId: map['parent_task_id'], // Thêm parent_task_id
      focusTimeMinutes:
          map['focus_time_minutes'] ??
          25, // Thêm focus_time_minutes với mặc định 25
      // subtaskIds sẽ được load riêng từ service
    );
  }

  /// Kiểm tra task có quá hạn không
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Kiểm tra task có đến hạn hôm nay không
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Kiểm tra task có đến hạn trong tuần này không
  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return dueDate!.isAfter(weekStart) && dueDate!.isBefore(weekEnd);
  }

  /// Lấy số ngày còn lại đến hạn
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    return difference;
  }

  /// Lấy màu sắc theo priority
  String get priorityColorHex {
    switch (priority) {
      case TaskPriority.low:
        return '#4CAF50'; // Green
      case TaskPriority.medium:
        return '#FF9800'; // Orange
      case TaskPriority.high:
        return '#F44336'; // Red
      case TaskPriority.urgent:
        return '#9C27B0'; // Purple
    }
  }

  /// Lấy màu sắc theo category
  String get categoryColorHex {
    switch (category) {
      case TaskCategory.work:
        return '#2196F3'; // Blue
      case TaskCategory.personal:
        return '#4CAF50'; // Green
      case TaskCategory.learning:
        return '#FF9800'; // Orange
      case TaskCategory.health:
        return '#E91E63'; // Pink
      case TaskCategory.finance:
        return '#9C27B0'; // Purple
      case TaskCategory.social:
        return '#00BCD4'; // Cyan
      case TaskCategory.other:
        return '#607D8B'; // Blue Grey
    }
  }

  /// Getter để tương thích với categoryId (sử dụng category name)
  String? get categoryId => category.name;

  /// Kiểm tra xem task này có phải là subtask không
  bool get isSubtask => parentTaskId != null;

  /// Kiểm tra xem task này có subtasks không
  bool get hasSubtasks => subtaskIds.isNotEmpty;

  /// Tính phần trăm hoàn thành của subtasks (nếu có)
  double getSubtaskProgress(List<String> completedSubtaskIds) {
    if (subtaskIds.isEmpty) return 0.0;
    final completedCount = subtaskIds
        .where((id) => completedSubtaskIds.contains(id))
        .length;
    return completedCount / subtaskIds.length;
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, category: $category, priority: $priority, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

