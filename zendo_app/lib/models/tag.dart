/*
 * Tên: models/tag.dart
 * Tác dụng: Khai báo model Tag cho gắn nhãn nhiệm vụ/phiên tập trung, gồm id, userId, name, color, sortOrder.
 * Khi nào dùng: Khi cần quản lý hệ thống tag, gắn tag vào Task hoặc FocusSession, và đồng bộ dữ liệu với Supabase.
 */

/// Model định nghĩa cấu trúc dữ liệu Tag.
class Tag {
  /// UUID của tag.
  final String id;

  /// ID người dùng sở hữu tag.
  final String userId;

  /// Tên tag hiển thị với người dùng.
  final String name;

  /// Màu sắc dạng hex giúp nhận diện nhanh trong UI.
  final String color;

  /// Thứ tự sắp xếp khi hiển thị list tag.
  final int sortOrder;

  /// Thời điểm tạo bản ghi.
  final DateTime createdAt;

  /// Thời điểm cập nhật gần nhất.
  final DateTime updatedAt;

  const Tag({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Chuyển Tag thành Map (Supabase/local DB).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Tạo Tag từ Map.
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      color: map['color'] as String? ?? '#9CA3AF',
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Copy với các thay đổi nhỏ.
  Tag copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tag(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}