import 'dart:convert';

class PollOption {
  final int id;
  final String text;
  int votes;

  PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'],
      text: json['text'] ?? '',
      votes: json['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
    };
  }
}

class Poll {
  final int pollID;
  final int postID;
  final String title;
  final List<PollOption> options;
  final int duration;
  final Map<int, int> voterMap;

  Poll({
    required this.pollID,
    required this.postID,
    required this.title,
    required this.options,
    required this.duration,
    Map<int, int>? voterMap,
  }) : voterMap = voterMap ?? {};

  factory Poll.fromJson(Map<String, dynamic> json) {
    List<PollOption> parsedOptions = [];

    final rawOptions = json['options'];
    try {
      if (rawOptions is String && rawOptions.trim().isNotEmpty) {
        parsedOptions = List<Map<String, dynamic>>.from(jsonDecode(rawOptions))
            .map((o) => PollOption.fromJson(o))
            .toList();
      } else if (rawOptions is List) {
        parsedOptions =
            rawOptions.map((o) => PollOption.fromJson(o)).toList();
      }
    } catch (e) {
      parsedOptions = [];
    }

    return Poll(
      pollID: json['pollID'],
      postID: json['postID'],
      title: json['title'] ?? '',
      options: parsedOptions,
      duration: json['duration'] ?? 0,
      voterMap: {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pollID': pollID,
      'postID': postID,
      'title': title,
      'options': jsonEncode(options.map((o) => o.toJson()).toList()),
      'duration': duration,
    };
  }
}
