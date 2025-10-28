/*
 * Tên: models/user.dart
 * Tác dụng: Model thông tin người dùng (id, email, displayName, avatarUrl, settings), dùng cho đồng bộ với Supabase và các provider.
 * Khi nào dùng: Khi lưu/hiển thị cấu hình người dùng, quản lý session đăng nhập và ánh xạ dữ liệu người dùng giữa UI và database.
 */

/// Model thông tin người dùng ứng dụng ZenDo.
class ZendoUser {
  /// UUID từ Supabase Auth.
  final String id;

  /// Email đăng nhập của người dùng.
  final String email;

  /// Tên hiển thị (có thể null nếu chưa cập nhật).
  final String? displayName;

  /// URL ảnh đại diện (Supabase Storage hoặc external), nullable.
  final String? avatarUrl;

  /// Ngôn ngữ ưu tiên của người dùng.
  final String locale;

  /// Chế độ theme người dùng lựa chọn (system/light/dark).
  final String themeMode;

  /// Thời điểm tạo bản ghi.
  final DateTime createdAt;

  /// Thời điểm cập nhật gần nhất.
  final DateTime updatedAt;

  const ZendoUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.locale = 'vi',
    this.themeMode = 'system',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo user từ Map (Supabase).
  factory ZendoUser.fromMap(Map<String, dynamic> map) {
    return ZendoUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      displayName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      locale: map['locale'] as String? ?? 'vi',
      themeMode: map['theme_mode'] as String? ?? 'system',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Chuyển đổi user thành Map để lưu trữ.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': displayName,
      'avatar_url': avatarUrl,
      'locale': locale,
      'theme_mode': themeMode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy với các trường tuỳ chỉnh.
  ZendoUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? locale,
    String? themeMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ZendoUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}