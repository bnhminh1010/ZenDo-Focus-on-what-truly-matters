/*
 * Tên: models/reminder.dart
 * Tác dụng: Khai báo model Reminder để nhắc việc cho Task/FocusSession, gồm thời điểm, lặp lại, kênh thông báo và trạng thái gửi.
 * Khi nào dùng: Khi cần thiết lập và đồng bộ lời nhắc (notifications) với dịch vụ nền, hiển thị lịch nhắc trong ứng dụng.
 */

/// Mục tiêu áp dụng reminder (task hay focus session).
enum ReminderTargetType { task, focusSession }

/// Kênh gửi thông báo.
enum ReminderChannel { push, email, inApp }

/// Quy tắc lặp lại reminder.
enum ReminderRepeat { none, daily, weekly, monthly }

/// Model định nghĩa cấu trúc dữ liệu của một Reminder.
class Reminder {
  /// UUID của reminder.
  final String id;

  /// ID người dùng sở hữu reminder.
  final String userId;

  /// ID thực thể được nhắc (task hoặc focus session).
  final String targetId;

  /// Loại thực thể được nhắc.
  final ReminderTargetType targetType;

  /// Thời điểm nhắc chính xác.
  final DateTime remindAt;

  /// Quy tắc lặp lại (nếu có).
  final ReminderRepeat repeatRule;

  /// Kênh gửi thông báo.
  final ReminderChannel channel;

  /// Đánh dấu đã gửi thành công hay chưa.
  final bool isSent;

  /// Thời điểm tạo bản ghi.
  final DateTime createdAt;

  /// Thời điểm cập nhật gần nhất.
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.remindAt,
    this.repeatRule = ReminderRepeat.none,
    this.channel = ReminderChannel.inApp,
    this.isSent = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo Reminder từ Map (Supabase/local DB).
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      targetId: map['target_id'] as String,
      targetType: ReminderTargetType.values.firstWhere(
        (e) => e.name == map['target_type'],
        orElse: () => ReminderTargetType.task,
      ),
      remindAt: DateTime.parse(map['remind_at'] as String),
      repeatRule: ReminderRepeat.values.firstWhere(
        (e) => e.name == map['repeat_rule'],
        orElse: () => ReminderRepeat.none,
      ),
      channel: ReminderChannel.values.firstWhere(
        (e) => e.name == map['channel'],
        orElse: () => ReminderChannel.inApp,
      ),
      isSent: map['is_sent'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Chuyển Reminder thành Map để lưu trữ/serialize.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'target_id': targetId,
      'target_type': targetType.name,
      'remind_at': remindAt.toIso8601String(),
      'repeat_rule': repeatRule.name,
      'channel': channel.name,
      'is_sent': isSent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Tạo bản copy với các thay đổi.
  Reminder copyWith({
    String? id,
    String? userId,
    String? targetId,
    ReminderTargetType? targetType,
    DateTime? remindAt,
    ReminderRepeat? repeatRule,
    ReminderChannel? channel,
    bool? isSent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      remindAt: remindAt ?? this.remindAt,
      repeatRule: repeatRule ?? this.repeatRule,
      channel: channel ?? this.channel,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}