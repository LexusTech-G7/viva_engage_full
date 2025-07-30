import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import 'user_info_card.dart';

class CommentBox extends StatelessWidget {
  final Comment c;
  const CommentBox({super.key, required this.c});

  Future<void> _showUserInfo(BuildContext context, int userID) async {
    try {
      final userInfo = await UserService().fetchUserById(userID);
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => UserInfoCard(user: userInfo),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải thông tin người dùng')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () => _showUserInfo(context, c.userID),
        child: CircleAvatar(
          backgroundImage: (c.avatarURL != null && c.avatarURL!.isNotEmpty)
              ? NetworkImage(c.avatarURL!)
              : null,
          child: (c.avatarURL == null || c.avatarURL!.isEmpty)
              ? Text(c.author[0].toUpperCase())
              : null,
        ),
      ),
      title: GestureDetector(
        onTap: () => _showUserInfo(context, c.userID),
        child: Text(
          c.author,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      subtitle: Text(c.commentText),
      trailing: Text(
        '${c.createdAt.hour}:${c.createdAt.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
