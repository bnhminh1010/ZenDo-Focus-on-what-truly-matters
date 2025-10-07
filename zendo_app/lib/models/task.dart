/// Enum định nghĩa các loại task category
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

/// Enum định nghĩa mức độ ưu tiên của task
enum TaskPriority {
  low('Thấp'),
  medium('Trung bình'),
  high('Cao'),
  urgent('Khẩn cấp');

  const TaskPriority(this.displayName);
  final String displayName;

  /// Thứ tự ưu tiên (số càng cao càng ưu tiên)
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

  /// So sánh priority để sort
  int compareTo(TaskPriority other) {
    return priorityOrder.compareTo(other.priorityOrder);
  }
}

/// Model định nghĩa cấu trúc dữ liệu của một Task
class Task {
  final String id;
  final String title;
  final String? description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<String> tags;
  final String? notes;
  final int estimatedMinutes;
  final int actualMinutes;

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
  });

  /// Tạo bản copy của Task với các thay đổi
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
    );
  }

  /// Chuyển đổi Task thành Map để lưu trữ
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
