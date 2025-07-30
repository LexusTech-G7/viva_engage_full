class Reaction {
  final int reactionID;
  final int userID;
  final String targetType; // 'post', 'comment', ...
  final int postID;
  final String emoji;
  final DateTime createdAt;

  Reaction({
    required this.reactionID,
    required this.userID,
    required this.targetType,
    required this.postID,
    required this.emoji,
    required this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        reactionID: json['reactionID'] ?? 0,
        userID: json['userID'] ?? 0,
        targetType: json['targetType']?.toString() ?? '',
        postID: json['postID'] ?? 0,
        emoji: json['emoji']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
