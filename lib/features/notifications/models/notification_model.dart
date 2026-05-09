class NotificationModel {
  final int id;
  final String message;
  final String createdAt;
  final bool isRead;
  final int recipientId;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.recipientId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      recipientId: json['recipient'] as int? ?? 0,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      recipientId: recipientId,
    );
  }
}
