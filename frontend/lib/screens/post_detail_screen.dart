import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';
import '../widgets/post_full_card.dart';

class PostDetailScreen extends StatefulWidget {
  final User currentUser;
  final int postID;

  const PostDetailScreen({
    super.key,
    required this.currentUser,
    required this.postID,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPost(widget.postID);
  }

  Future<void> _loadPost(int postID) async {
    setState(() => _loading = true);
    try {
      final post = await PostService().fetchPostByID(postID);
      setState(() {
        _post = post;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải bài viết: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài viết')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? const Center(child: Text('Không tìm thấy bài viết'))
              : SingleChildScrollView(
                  child: PostFullCard(
                    post: _post!,
                    currentUser: widget.currentUser,
                  ),
                ),
    );
  }
}
