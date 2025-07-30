import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/post.dart';
import '../models/community.dart';
import '../models/notification.dart';

import '../widgets/post_full_card.dart';
import '../screens/create_post.dart';
import '../screens/community_list.dart';
import '../screens/notification_screen.dart';
import '../screens/profile.dart';
import '../screens/post_detail_screen.dart'; // 👈 thêm import

import '../services/post_service.dart';
import '../services/community_service.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  final User user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _loading = true;
  List<Post> _posts = [];
  List<Community> _communities = [];
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 initState DashboardScreen for user: ${widget.user.userID}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_posts.isEmpty) {
        _loadDashboardData();
      }
    });
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint("♻️ didUpdateWidget DashboardScreen");
    if (oldWidget.user.userID != widget.user.userID) {
      debugPrint("👤 User changed! Reloading dashboard...");
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);

    List<Post> posts = [];
    List<Community> communities = [];
    List<NotificationItem> notifications = [];

    try {
      posts = await PostService().fetchPostsForUser(widget.user.userID);
      debugPrint("📡 API trả về ${posts.length} posts");
    } catch (e) {
      debugPrint("⚠️ Lỗi fetch posts: $e");
    }

    try {
      communities = await CommunityService.getAllCommunities(widget.user.userID);
    } catch (e) {
      debugPrint("⚠️ Lỗi fetch communities: $e");
    }

    try {
      notifications = await NotificationService.getAllNotifications();
    } catch (e) {
      debugPrint("⚠️ Lỗi fetch notifications: $e");
    }

    if (mounted) {
      setState(() {
        _posts = posts;
        _communities = communities;
        _notifications = notifications;
        _loading = false;
      });
    }
  }

  Widget _buildFeed() {
    final visiblePosts = List<Post>.from(_posts)
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    return visiblePosts.isEmpty
        ? const Center(child: Text('Không có bài viết phù hợp'))
        : RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: ListView.builder(
              itemCount: visiblePosts.length,
              itemBuilder: (_, i) {
                final post = visiblePosts[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(
                          currentUser: widget.user,
                          postID: post.postID,
                        ),
                      ),
                    );
                  },
                  child: PostFullCard(
                    post: post,
                    currentUser: widget.user,
                  ),
                );
              },
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildFeed(),
      CommunityListScreen(currentUser: widget.user),
      NotificationScreen(currentUser: widget.user),
      ProfileScreen(user: widget.user),
    ];

    final titles = ['Viva Feed', 'Communities', 'Notifications', 'Profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${titles[_selectedIndex]} - ${widget.user.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                widget.user.email,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePostScreen(currentUser: widget.user),
                  ),
                );
                _loadDashboardData();
              },
              icon: const Icon(Icons.add),
              label: const Text('Tạo bài viết'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) _loadDashboardData(); // reload notification
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notify'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
