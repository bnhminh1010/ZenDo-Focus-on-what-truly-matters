/// Category Class
/// Tác dụng: Model quản lý danh mục task tùy chỉnh của người dùng
/// Sử dụng khi: Tạo, lưu trữ và quản lý các danh mục task do người dùng tự định nghĩa
class Category {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String icon;
  final String color;
  final bool isDefault;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.sortOrder = 0,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// fromJson factory constructor
  /// Tác dụng: Tạo Category object từ JSON data nhận từ Supabase
  /// Sử dụng khi: Deserialize dữ liệu category từ database
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? '📝',
      color: json['color'] as String? ?? '#3B82F6',
      isDefault: json['is_default'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// toJson method
  /// Tác dụng: Chuyển Category object thành JSON để gửi lên Supabase
  /// Sử dụng khi: Serialize category để lưu vào database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'is_default': isDefault,
      'sort_order': sortOrder,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Tạo bản copy với các thay đổi
  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isDefault,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, color: $color)';
  }
}

/// Predefined categories cho user mới
class DefaultCategories {
  static const List<Map<String, dynamic>> defaults = [
    {
      'name': 'Công việc',
      'description': 'Các task liên quan đến công việc',
      'icon': '💼',
      'color': '#3B82F6',
      'is_default': true,
      'sort_order': 1,
    },
    {
      'name': 'Cá nhân',
      'description': 'Các task cá nhân và sở thích',
      'icon': '👤',
      'color': '#10B981',
      'is_default': true,
      'sort_order': 2,
    },
    {
      'name': 'Học tập',
      'description': 'Các task học tập và phát triển bản thân',
      'icon': '📚',
      'color': '#8B5CF6',
      'is_default': true,
      'sort_order': 3,
    },
    {
      'name': 'Sức khỏe',
      'description': 'Các task liên quan đến sức khỏe và thể dục',
      'icon': '❤️',
      'color': '#EF4444',
      'is_default': true,
      'sort_order': 4,
    },
    {
      'name': 'Tài chính',
      'description': 'Các task quản lý tài chính',
      'icon': '💰',
      'color': '#F59E0B',
      'is_default': true,
      'sort_order': 5,
    },
    {
      'name': 'Xã hội',
      'description': 'Các task liên quan đến gia đình và bạn bè',
      'icon': '👥',
      'color': '#EC4899',
      'is_default': true,
      'sort_order': 6,
    },
    {
      'name': 'Khác',
      'description': 'Các task khác',
      'icon': '📝',
      'color': '#6B7280',
      'is_default': true,
      'sort_order': 7,
    },
  ];
}

