/// FocusSession Class
/// Tác dụng: Model quản lý phiên tập trung/pomodoro của người dùng
/// Sử dụng khi: Theo dõi và lưu trữ thông tin các phiên làm việc tập trung
class FocusSession {
  final String? id;
  final String userId;
  final String? taskId;
  final String? title;
  final int plannedDurationMinutes;
  final int actualDurationMinutes;
  final int breakDurationMinutes;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime? pausedAt;
  final int totalPauseDurationMinutes;
  final FocusSessionStatus status;
  final String sessionType;
  final int? productivityRating;
  final int distractionCount;
  final String? notes;
  final String? backgroundSound;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FocusSession({
    this.id,
    required this.userId,
    this.taskId,
    this.title,
    required this.plannedDurationMinutes,
    this.actualDurationMinutes = 0,
    this.breakDurationMinutes = 5,
    required this.startedAt,
    this.endedAt,
    this.pausedAt,
    this.totalPauseDurationMinutes = 0,
    this.status = FocusSessionStatus.active,
    this.sessionType = 'pomodoro',
    this.productivityRating,
    this.distractionCount = 0,
    this.notes,
    this.backgroundSound,
    required this.createdAt,
    required this.updatedAt,
  });

  /// fromSupabaseMap factory constructor
  /// Tác dụng: Tạo FocusSession object từ Map data nhận từ Supabase
  /// Sử dụng khi: Deserialize dữ liệu focus session từ database
  factory FocusSession.fromSupabaseMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      taskId: map['task_id'] as String?,
      title: map['title'] as String?,
      plannedDurationMinutes: map['planned_duration_minutes'] as int? ?? 25,
      actualDurationMinutes: map['actual_duration_minutes'] as int? ?? 0,
      breakDurationMinutes: map['break_duration_minutes'] as int? ?? 5,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
      pausedAt: map['paused_at'] != null
          ? DateTime.parse(map['paused_at'] as String)
          : null,
      totalPauseDurationMinutes:
          map['total_pause_duration_minutes'] as int? ?? 0,
      status: _parseStatus(map['status'] as String?),
      sessionType: map['session_type'] as String? ?? 'pomodoro',
      productivityRating: map['productivity_rating'] as int?,
      distractionCount: map['distraction_count'] as int? ?? 0,
      notes: map['notes'] as String?,
      backgroundSound: map['background_sound'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Chuyển đổi FocusSession thành Map cho Supabase
  Map<String, dynamic> toSupabaseMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      'planned_duration_minutes': plannedDurationMinutes,
      'actual_duration_minutes': actualDurationMinutes,
      'break_duration_minutes': breakDurationMinutes,
      'started_at': startedAt.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
      if (pausedAt != null) 'paused_at': pausedAt!.toIso8601String(),
      'total_pause_duration_minutes': totalPauseDurationMinutes,
      'status': status.name,
      'session_type': sessionType,
      if (productivityRating != null) 'productivity_rating': productivityRating,
      'distraction_count': distractionCount,
      if (notes != null) 'notes': notes,
      if (backgroundSound != null) 'background_sound': backgroundSound,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Parse status từ string
  static FocusSessionStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return FocusSessionStatus.active;
      case 'paused':
        return FocusSessionStatus.paused;
      case 'completed':
        return FocusSessionStatus.completed;
      case 'cancelled':
        return FocusSessionStatus.cancelled;
      default:
        return FocusSessionStatus.active;
    }
  }

  /// Copy with method để tạo instance mới với một số thay đổi
  FocusSession copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? title,
    int? plannedDurationMinutes,
    int? actualDurationMinutes,
    int? breakDurationMinutes,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? pausedAt,
    int? totalPauseDurationMinutes,
    FocusSessionStatus? status,
    String? sessionType,
    int? productivityRating,
    int? distractionCount,
    String? notes,
    String? backgroundSound,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      plannedDurationMinutes:
          plannedDurationMinutes ?? this.plannedDurationMinutes,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      totalPauseDurationMinutes:
          totalPauseDurationMinutes ?? this.totalPauseDurationMinutes,
      status: status ?? this.status,
      sessionType: sessionType ?? this.sessionType,
      productivityRating: productivityRating ?? this.productivityRating,
      distractionCount: distractionCount ?? this.distractionCount,
      notes: notes ?? this.notes,
      backgroundSound: backgroundSound ?? this.backgroundSound,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FocusSession(id: $id, title: $title, duration: ${plannedDurationMinutes}min, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FocusSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum cho trạng thái Focus Session
/// Tương ứng với focus_session_status trong database
enum FocusSessionStatus { active, paused, completed, cancelled }

/// Extension để lấy display name cho status
extension FocusSessionStatusExtension on FocusSessionStatus {
  String get displayName {
    switch (this) {
      case FocusSessionStatus.active:
        return 'Đang hoạt động';
      case FocusSessionStatus.paused:
        return 'Tạm dừng';
      case FocusSessionStatus.completed:
        return 'Hoàn thành';
      case FocusSessionStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get name {
    switch (this) {
      case FocusSessionStatus.active:
        return 'active';
      case FocusSessionStatus.paused:
        return 'paused';
      case FocusSessionStatus.completed:
        return 'completed';
      case FocusSessionStatus.cancelled:
        return 'cancelled';
    }
  }
}

