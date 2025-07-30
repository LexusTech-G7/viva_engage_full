import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/community.dart';

class CommunityService {
  static const String baseUrl = 'http://localhost:3000/api/communities';

  // Lấy danh sách cộng đồng kèm trạng thái joined
  static Future<List<Community>> getAllCommunities(int userID) async {
    final res = await http.get(Uri.parse('$baseUrl/$userID'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Community.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load communities');
    }
  }

  // Tham gia cộng đồng
  static Future<void> joinCommunity(int userID, int communityID) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$communityID/join'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userID': userID}),
    );

    if (res.statusCode != 200) {
      throw Exception('Join failed');
    }
  }

  // Rời cộng đồng
  static Future<void> leaveCommunity(int userID, int communityID) async {
    final res = await http.post(
      Uri.parse('$baseUrl/$communityID/leave'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userID': userID}),
    );

    if (res.statusCode != 200) {
      throw Exception('Leave failed');
    }
  }

  // Toggle trạng thái join/leave
  static Future<void> toggleJoinCommunity(
      int userID, Community community) async {
    if (community.joined) {
      await leaveCommunity(userID, community.communityID);
    } else {
      await joinCommunity(userID, community.communityID);
    }
  }
}
