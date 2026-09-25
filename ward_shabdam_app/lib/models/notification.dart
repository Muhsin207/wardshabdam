class AppNotification {
  final int id;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
    );
  }
}
