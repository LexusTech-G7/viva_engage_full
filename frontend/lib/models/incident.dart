class Incident {
  final int incidentID;
  final int postID;
  final String severity;
  final String location;
  final String status;
  final int openedBy;
  final String openedByName;
  final DateTime openedAt;
  final int? closedBy;
  final String? closedByName;
  final DateTime? closedAt;
  final int? secondsToClose;

  Incident({
    required this.incidentID,
    required this.postID,
    required this.severity,
    required this.location,
    required this.status,
    required this.openedBy,
    required this.openedByName,
    required this.openedAt,
    this.closedBy,
    this.closedByName,
    this.closedAt,
    this.secondsToClose,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      incidentID: json['incidentID'],
      postID: json['postID'],
      severity: json['severity'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      openedBy: json['openedBy'],
      openedByName: json['openedByName'] ?? '',
      openedAt: DateTime.parse(json['openedAt']),
      closedBy: json['closedBy'],
      closedByName: json['closedByName'],
      closedAt:
          json['closedAt'] != null ? DateTime.tryParse(json['closedAt']) : null,
      secondsToClose: json['secondsToClose'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incidentID': incidentID,
      'postID': postID,
      'severity': severity,
      'location': location,
      'status': status,
      'openedBy': openedBy,
      'openedByName': openedByName,
      'openedAt': openedAt.toIso8601String(),
      'closedBy': closedBy,
      'closedByName': closedByName,
      'closedAt': closedAt?.toIso8601String(),
      'secondsToClose': secondsToClose,
    };
  }
}
