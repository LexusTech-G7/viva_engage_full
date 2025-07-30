class Question {
  final int questionID;
  final int postID;
  final String questionText;
  final bool isResolved;
  final DateTime? resolvedAt;
  final int? answerID;

  Question({
    required this.questionID,
    required this.postID,
    required this.questionText,
    required this.isResolved,
    this.resolvedAt,
    this.answerID,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        questionID: json['questionID'],
        postID: json['postID'],
        questionText: json['questionText'],
        isResolved: json['isResolved'] == 1,
        resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
        answerID: json['answerID'],
      );
}
