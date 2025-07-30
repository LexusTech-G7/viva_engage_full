class Comment {
  final int commentID;
  final int userID;
  final int postID;
  final String commentText;
  final DateTime createdAt;
  final String author;
  final String avatarURL;

  Comment({
    required this.commentID,
    required this.userID,
    required this.postID,
    required this.commentText,
    required this.createdAt,
    required this.author,
    required this.avatarURL,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        commentID: json['commentID'],
        userID: json['userID'],
        postID: json['postID'],
        commentText: json['commentText'],
        createdAt: DateTime.parse(json['createdAt']),
        author: json['author'],
        avatarURL: json['avatarURL'] ?? '',
      );

  Map<String, dynamic> toJson() {
    return {
      'commentID': commentID,
      'userID': userID,
      'postID': postID,
      'commentText': commentText,
      'createdAt': createdAt.toIso8601String(),
      'author': author,
      'avatarURL': avatarURL,
    };
  }
}
