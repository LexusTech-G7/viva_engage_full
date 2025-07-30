class NotificationItem {
  final int notificationID;
  final String senderName;
  final String notificationText;
  final String targetType; // post, comment, poll
  final int targetID;
  final DateTime createdAt;

  NotificationItem({
    required this.notificationID,
    required this.senderName,
    required this.notificationText,
    required this.targetType,
    required this.targetID,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationID: json['notificationID'],
      senderName: json['senderName'] ?? 'Hệ thống',
      notificationText: json['notificationText'] ?? '',
      targetType: json['targetType'] ?? '',
      targetID: json['targetID'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
