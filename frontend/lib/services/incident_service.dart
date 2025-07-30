import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/incident.dart';

class IncidentService {
  static const String baseUrl = 'http://localhost:3000/api/incidents';

  /// Lấy incident theo postID
  static Future<Incident?> getIncidentByPostId(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/post/$postId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Incident.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load incident');
    }
  }

  /// Tạo incident mới
  static Future<void> createIncident(Map<String, dynamic> incidentData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(incidentData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create incident');
    }
  }

  /// Đóng incident
  static Future<void> closeIncident(int incidentId, int closedBy) async {
    final response = await http.put(
      Uri.parse('$baseUrl/close/$incidentId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'closedBy': closedBy}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to close incident');
    }
  }
}
