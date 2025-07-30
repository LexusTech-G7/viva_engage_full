import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:3000/api/notifications';

  static Future<List<NotificationItem>> getAllNotifications() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => NotificationItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }
}
