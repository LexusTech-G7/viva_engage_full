import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/poll.dart';

class PollService {
  static const String baseUrl = 'http://localhost:3000/api/polls';

  // Lấy poll theo postID
  static Future<Poll> getPollByPostId(int postID) async {
    final res = await http.get(Uri.parse('$baseUrl/post/$postID'));
    if (res.statusCode == 200) {
      return Poll.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 404) {
      throw Exception('Poll not found');
    } else {
      throw Exception('Failed to load poll');
    }
  }

  // Gửi vote
  static Future<void> vote(int pollID, int optionID, int userID) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$pollID/vote'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'optionID': optionID,
        'userID': userID,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Vote failed: ${res.body}');
    }
  }

  // Tạo poll mới
  static Future<void> createPoll(Map<String, dynamic> pollData) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pollData),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create poll: ${res.body}');
    }
  }
}
