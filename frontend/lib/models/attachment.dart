class Attachment {
  final int attachmentID;
  final int postID;
  final String name;
  final String type;
  final String url;
  final int uploadedBy;
  final DateTime uploadedAt;

  Attachment({
    required this.attachmentID,
    required this.postID,
    required this.name,
    required this.type,
    required this.url,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
        attachmentID: json['attachmentID'],
        postID: json['postID'],
        name: json['name'],
        type: json['type'],
        url: json['url'],
        uploadedBy: json['uploadedBy'],
        uploadedAt: DateTime.parse(json['uploadedAt']),
      );
}
