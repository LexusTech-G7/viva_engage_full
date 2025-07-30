import 'package:flutter/material.dart';
import '../models/incident.dart';

class IncidentInfoWidget extends StatelessWidget {
  final Incident incident;

  const IncidentInfoWidget({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🚨 SỰ CỐ', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('• Mức độ: ${incident.severity}'),
          Text('• Trạng thái: ${incident.status}'),
          if (incident.status == 'closed') ...[
            Text('• Đóng bởi: ${incident.closedBy ?? "Không rõ"}'),
            Text('• Thời gian đóng: ${incident.closedAt ?? "Không rõ"}'),
            Text(
              '• Tổng thời gian xử lý: ${incident.secondsToClose != null ? incident.secondsToClose! ~/ 60 : "?"} phút',
            ),
          ]
        ],
      ),
    );
  }
}
