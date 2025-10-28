/*
 * Tên: models/subtask.dart
 * Tác dụng: Model nhiệm vụ con của Task, quản lý trạng thái hoàn thành, thứ tự, thời gian tạo/cập nhật và mô tả.
 * Khi nào dùng: Khi hiển thị/ghi lưu danh sách subtasks của một Task, thao tác complete/uncomplete và đồng bộ dữ liệu.
 */

/// Model định nghĩa cấu trúc dữ liệu của một Subtask
class Subtask {
  /// UUID của subtask.
  final String id;

  /// ID của task cha, đảm bảo mỗi subtask thuộc về một task cụ thể.
  final String taskId; // ID của task cha

  /// Tiêu đề ngắn gọn của subtask.
  final String title;

  /// Mô tả chi tiết (nullable) nếu cần giải thích thêm.
  final String? description;

  /// Trạng thái hoàn thành của subtask.
  final bool isCompleted;

  /// Thời điểm đánh dấu hoàn thành (nullable).
  final DateTime? completedAt;

  /// Thứ tự hiển thị trong danh sách subtasks của task.
  final int sortOrder;

  /// Dấu thời gian tạo bản ghi.
  final DateTime createdAt;

  /// Dấu thời gian cập nhật lần cuối.
  final DateTime updatedAt;

  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.completedAt,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo bản copy của Subtask với các thay đổi
  Subtask copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Chuyển đổi Subtask thành Map để lưu vào database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Tạo Subtask từ Map (từ database)
  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'] ?? '',
      taskId: map['task_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      isCompleted: map['is_completed'] ?? false,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      sortOrder: map['sort_order'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  /// Tạo Subtask từ Supabase Map
  factory Subtask.fromSupabaseMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'] ?? '',
      taskId: map['task_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      isCompleted: map['is_completed'] ?? false,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      sortOrder: map['sort_order'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  /// Chuyển đổi thành JSON string
  String toJson() {
    return toMap().toString();
  }

  @override
  String toString() {
    return 'Subtask(id: $id, taskId: $taskId, title: $title, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subtask && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

