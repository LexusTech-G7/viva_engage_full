import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../models/user.dart';

class NotificationScreen extends StatefulWidget {
  final User currentUser;
  const NotificationScreen({super.key, required this.currentUser});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await NotificationService.getAllNotifications();
      setState(() {
        _notifications = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thông báo: $e')),
      );
    }
  }

  void _openTarget(NotificationItem n) {
  if (n.targetType == 'post') {
    Navigator.pushNamed(
      context,
      '/postDetail',
      arguments: {
        'postID': n.targetID,
        'currentUser': widget.currentUser,
      },
    );
  } else if (n.targetType == 'comment') {
    Navigator.pushNamed(
      context,
      '/commentDetail',
      arguments: {
        'commentID': n.targetID,
        'currentUser': widget.currentUser,
      },
    );
  } else if (n.targetType == 'poll') {
    Navigator.pushNamed(
      context,
      '/pollDetail',
      arguments: {
        'pollID': n.targetID,
        'currentUser': widget.currentUser,
      },
    );
  } else {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không thể mở thông báo này')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm • dd/MM');

    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Không có thông báo'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (_, i) {
                    final n = _notifications[i];
                    return ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text('${n.senderName} - ${n.notificationText}'),
                      subtitle: Text(dateFormat.format(n.createdAt)),
                      onTap: () => _openTarget(n),
                    );
                  },
                ),
    );
  }
}
