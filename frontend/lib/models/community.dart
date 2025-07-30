class Community {
  final int communityID;
  final String name;
  final String? desc;
  final int createdBy;
  final DateTime createdAt;
  final bool visibility;
  bool joined; // true nếu user đã tham gia

  Community({
    required this.communityID,
    required this.name,
    this.desc,
    required this.createdBy,
    required this.createdAt,
    required this.visibility,
    this.joined = false,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
  return Community(
    communityID: json['communityID'] ?? 0,
    name: json['name'] ?? '',
    desc: json['desc'],
    createdBy: json['createdBy'] ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    visibility: (json['visibility'] ?? 0) == 1,
    joined: (json['joined'] ?? 0) == 1,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'communityID': communityID,
      'name': name,
      'desc': desc,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'visibility': visibility ? 1 : 0,
      'joined': joined ? 1 : 0,
    };
  }
}
