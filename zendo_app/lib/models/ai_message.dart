import 'package:equatable/equatable.dart';

/// Enum cho loại tin nhắn AI
enum MessageType { user, ai, system }

/// Enum cho trạng thái tin nhắn
enum MessageStatus { sending, sent, delivered, error }

/// Model cho tin nhắn chat với AI
class AIMessage extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final String? errorMessage;

  const AIMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.userId,
    this.metadata,
    this.errorMessage,
  });

  /// Tạo tin nhắn từ user
  factory AIMessage.fromUser({
    required String id,
    required String content,
    required String userId,
    MessageStatus status = MessageStatus.sending,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id,
      content: content,
      type: MessageType.user,
      status: status,
      timestamp: DateTime.now(),
      userId: userId,
      metadata: metadata,
    );
  }

  /// Tạo tin nhắn từ AI
  factory AIMessage.fromAI({
    required String id,
    required String content,
    MessageStatus status = MessageStatus.delivered,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id,
      content: content,
      type: MessageType.ai,
      status: status,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Tạo tin nhắn system (thông báo, lỗi, etc.)
  factory AIMessage.system({
    required String id,
    required String content,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id,
      content: content,
      type: MessageType.system,
      status: MessageStatus.delivered,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Tạo tin nhắn lỗi
  factory AIMessage.error({
    required String id,
    required String content,
    required String errorMessage,
    String? userId,
  }) {
    return AIMessage(
      id: id,
      content: content,
      type: MessageType.system,
      status: MessageStatus.error,
      timestamp: DateTime.now(),
      userId: userId,
      errorMessage: errorMessage,
      metadata: {'isError': true},
    );
  }

  /// Tạo từ Map (từ database hoặc API)
  factory AIMessage.fromMap(Map<String, dynamic> map) {
    return AIMessage(
      id: map['id'] as String,
      content: map['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.user,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(map['timestamp'] as String),
      userId: map['user_id'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      errorMessage: map['error_message'] as String?,
    );
  }

  /// Chuyển đổi thành Map (để lưu database hoặc gửi API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
      'metadata': metadata,
      'error_message': errorMessage,
    };
  }

  /// Tạo từ Supabase Map
  factory AIMessage.fromSupabaseMap(Map<String, dynamic> map) {
    return AIMessage(
      id: map['id'] as String,
      content: map['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.user,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      errorMessage: map['error_message'] as String?,
    );
  }

  /// Chuyển đổi thành Supabase Map
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'status': status.name,
      'created_at': timestamp.toIso8601String(),
      'user_id': userId,
      'metadata': metadata,
      'error_message': errorMessage,
    };
  }

  /// Copy với các thay đổi
  AIMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? userId,
    Map<String, dynamic>? metadata,
    String? errorMessage,
  }) {
    return AIMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Kiểm tra xem tin nhắn có phải từ user không
  bool get isFromUser => type == MessageType.user;

  /// Kiểm tra xem tin nhắn có phải từ AI không
  bool get isFromAI => type == MessageType.ai;

  /// Kiểm tra xem tin nhắn có phải system không
  bool get isSystem => type == MessageType.system;

  /// Kiểm tra xem tin nhắn có lỗi không
  bool get hasError => status == MessageStatus.error;

  /// Kiểm tra xem tin nhắn đang được gửi không
  bool get isSending => status == MessageStatus.sending;

  /// Lấy thời gian hiển thị (format ngắn gọn)
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  /// Lấy avatar cho tin nhắn
  String get avatar {
    switch (type) {
      case MessageType.user:
        return '👤';
      case MessageType.ai:
        return '🤖';
      case MessageType.system:
        return '⚙️';
    }
  }

  @override
  List<Object?> get props => [
    id,
    content,
    type,
    status,
    timestamp,
    userId,
    metadata,
    errorMessage,
  ];

  @override
  String toString() {
    return 'AIMessage(id: $id, type: $type, status: $status, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}

