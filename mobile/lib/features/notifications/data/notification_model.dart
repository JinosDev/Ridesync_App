class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;   // "booking" | "delay" | "alert" | "promo"
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id:        json['id'] as String,
        title:     json['title'] as String,
        body:      json['body'] as String,
        type:      json['type'] as String? ?? 'alert',
        isRead:    json['isRead'] as bool? ?? false,
        createdAt: json['createdAt'] != null ? (json['createdAt'] as dynamic).toDate() : null,
      );
}
