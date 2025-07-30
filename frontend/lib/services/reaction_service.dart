import 'dart:convert';
import 'package:http/http.dart' as http;

class ReactionService {
  static const String baseUrl = 'http://localhost:3000/api/reactions';

  /// Toggle: nếu chưa có => add, nếu đã có => remove.
  /// Trả emoji, count sau khi cập nhật.
  static Future<Map<String, dynamic>> toggleReaction(
      int postID, String emoji, int userID) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$postID'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'emoji': emoji, 'userID': userID}),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 409) {
      // Reaction đã tồn tại => xóa
      final delRes = await http.delete(
        Uri.parse('$baseUrl/$postID'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'emoji': emoji, 'userID': userID}),
      );
      if (delRes.statusCode == 200) {
        return jsonDecode(delRes.body);
      } else {
        throw Exception('Failed to remove reaction: ${delRes.body}');
      }
    } else {
      throw Exception('Failed to react: ${res.body}');
    }
  }

  /// Lấy tất cả reaction của post
  static Future<Map<String, int>> getReactions(int postID) async {
    final res = await http.get(Uri.parse('$baseUrl/$postID'));
    if (res.statusCode == 200) {
      final raw = jsonDecode(res.body);
      return raw.map<String, int>(
          (k, v) => MapEntry(k.toString(), int.tryParse(v.toString()) ?? 0));
    } else {
      throw Exception('Failed to get reactions: ${res.body}');
    }
  }
}
