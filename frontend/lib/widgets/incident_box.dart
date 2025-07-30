import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';
import 'package:intl/intl.dart';

class IncidentBox extends StatefulWidget {
  final int postID;

  const IncidentBox({super.key, required this.postID});

  @override
  State<IncidentBox> createState() => _IncidentBoxState();
}

class _IncidentBoxState extends State<IncidentBox> {
  Incident? _incident;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIncident();
  }

  Future<void> _loadIncident() async {
    try {
      final data = await IncidentService.getIncidentByPostId(widget.postID);
      setState(() {
        _incident = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không tải được sự cố';
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_incident == null) return const SizedBox.shrink();

    final incident = _incident!;
    final Color severityColor = {
          'low': Colors.green,
          'medium': Colors.orange,
          'high': Colors.red,
        }[incident.severity.toLowerCase()] ??
        Colors.grey;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        border: Border.all(color: severityColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: severityColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "Sự cố (${incident.severity.toUpperCase()})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: severityColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("📍 Vị trí: ${incident.location}"),
          Text("👤 Mở bởi: ${incident.openedByName}"),
          Text("🕒 Thời gian mở: ${_formatDate(incident.openedAt)}"),
          Text("📌 Trạng thái: ${incident.status}"),
          if (incident.status.toLowerCase() == 'closed') ...[
            Text("✅ Đóng bởi: ${incident.closedByName ?? 'N/A'}"),
            Text(
                "🕒 Đóng lúc: ${incident.closedAt != null ? _formatDate(incident.closedAt!) : 'N/A'}"),
            if (incident.secondsToClose != null)
              Text("⏳ Xử lý: ${incident.secondsToClose! ~/ 60} phút"),
          ],
        ],
      ),
    );
  }
}
