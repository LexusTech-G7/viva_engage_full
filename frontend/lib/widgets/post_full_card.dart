import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/user.dart';
import '../models/attachment.dart';

import '../services/comment_service.dart';
import '../services/reaction_service.dart';
import '../services/attachment_service.dart';
import '../services/user_service.dart';

import 'comment_box.dart';
import 'poll_widget.dart';
import 'incident_box.dart';
import 'user_info_card.dart';

class PostFullCard extends StatefulWidget {
  final Post post;
  final User currentUser;

  const PostFullCard({
    super.key,
    required this.post,
    required this.currentUser,
  });

  @override
  State<PostFullCard> createState() => _PostFullCardState();
}

class _PostFullCardState extends State<PostFullCard> {
  final _commentCtrl = TextEditingController();
  List<Comment> _comments = [];
  List<Attachment> _attachments = [];
  bool _loadingComments = true;
  bool _loadingAttachments = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadAttachments();
  }

  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    try {
      _comments = await CommentService().fetchCommentsByPost(widget.post.postID);
    } catch (e) {
      debugPrint('⚠️ Lỗi load comment: $e');
    }
    setState(() => _loadingComments = false);
  }

  Future<void> _loadAttachments() async {
    setState(() => _loadingAttachments = true);
    try {
      _attachments = await AttachmentService.fetchAttachmentsByPost(widget.post.postID);
    } catch (e) {
      debugPrint('⚠️ Lỗi load attachment: $e');
    }
    setState(() => _loadingAttachments = false);
  }

  Future<void> _addComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    try {
      await CommentService().createComment(
        Comment(
          commentID: 0,
          userID: widget.currentUser.userID,
          postID: widget.post.postID,
          commentText: _commentCtrl.text.trim(),
          createdAt: DateTime.now(),
          author: widget.currentUser.name,
          avatarURL: widget.currentUser.avatarURL,
        ),
      );
      _commentCtrl.clear();
      await _loadComments();
    } catch (e) {
      debugPrint('⚠️ Lỗi tạo comment: $e');
    }
  }

  Future<void> _react(String emoji) async {
    try {
      final result = await ReactionService.toggleReaction(
        widget.post.postID,
        emoji,
        widget.currentUser.userID,
      );
      setState(() {
        widget.post.reactions[result['emoji']] =
            int.tryParse(result['count'].toString()) ?? 0;
      });
    } catch (e) {
      debugPrint('⚠️ Lỗi reaction: $e');
    }
  }

  Future<void> _showUserInfo(int userID) async {
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
        SnackBar(content: Text('Không thể tải thông tin người dùng')),
      );
    }
  }

  bool _isDriveLink(String url) => url.contains("drive.google.com");

  String _normalizeDriveUrl(String url) {
    final match = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (match != null) {
      return "https://drive.google.com/uc?export=view&id=${match.group(1)}";
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showUserInfo(post.userID),
                  child: CircleAvatar(
                    backgroundImage: widget.currentUser.avatarURL != null
                        ? NetworkImage(widget.currentUser.avatarURL!)
                        : null,
                    child: widget.currentUser.avatarURL == null
                        ? Text(post.author.isNotEmpty ? post.author[0] : '?')
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showUserInfo(post.userID),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.author,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${post.community}',
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
                if (post.isPinned)
                  const Icon(Icons.push_pin, color: Colors.red),
                const SizedBox(width: 4),
                Text('${post.viewCount} 👁️'),
              ],
            ),

            const SizedBox(height: 12),
            if (post.postType == 'incident') IncidentBox(postID: post.postID),
            if (post.postType == 'poll')
              PollWidget(postID: post.postID, currentUser: widget.currentUser)
            else
              Text(post.body),

            const SizedBox(height: 12),

            // Attachments
            if (_loadingAttachments)
              const Center(child: CircularProgressIndicator())
            else if (_attachments.isNotEmpty)
              Column(
                children: _attachments.map((a) {
                  if (a.type == 'image') {
                    final imgUrl =
                        _isDriveLink(a.url) ? _normalizeDriveUrl(a.url) : a.url;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                }).toList(),
              ),

            const SizedBox(height: 12),

            // Reactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: post.reactions.keys.map((emoji) {
                final count = post.reactions[emoji] ?? 0;
                return Column(
                  children: [
                    IconButton(
                      onPressed: () => _react(emoji),
                      icon: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    Text(count.toString()),
                  ],
                );
              }).toList(),
            ),

            const Divider(),

            if (_loadingComments)
              const Center(child: CircularProgressIndicator())
            else
              ..._comments.map((c) => CommentBox(c: c)),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Viết bình luận...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _addComment),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
