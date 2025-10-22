import 'package:flutter/foundation.dart';

/// Model định nghĩa cấu trúc dữ liệu của một Subtask
class Subtask {
  final String id;
  final String taskId; // ID của task cha
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sortOrder;
  final DateTime createdAt;
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

