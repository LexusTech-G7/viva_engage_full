import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/attachment.dart';

class AttachmentService {
  static const String baseUrl = 'http://localhost:3000/api/attachments';

  static Future<List<Attachment>> fetchAttachmentsByPost(int postID) async {
    final res = await http.get(Uri.parse('$baseUrl/post/$postID'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Attachment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch attachments');
    }
  }
}
