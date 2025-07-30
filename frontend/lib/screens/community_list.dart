import 'package:flutter/material.dart';
import '../models/community.dart';
import '../models/user.dart';
import '../services/community_service.dart';
import '../widgets/community_card.dart';

class CommunityListScreen extends StatefulWidget {
  final User currentUser;

  const CommunityListScreen({super.key, required this.currentUser});

  @override
  State<CommunityListScreen> createState() => _CommunityListScreenState();
}

class _CommunityListScreenState extends State<CommunityListScreen> {
  List<Community> _communities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    try {
      final data = await CommunityService.getAllCommunities(widget.currentUser.userID);
      if (!mounted) return;
      setState(() {
        _communities = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách: $e')),
      );
    }
  }

  Future<void> _toggleJoin(Community c) async {
    setState(() => _loading = true);
    await CommunityService.toggleJoinCommunity(widget.currentUser.userID, c);
    if (!mounted) return;
    await _loadCommunities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communities')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _communities.length,
              itemBuilder: (_, i) => CommunityCard(
                c: _communities[i],
                onToggle: () => _toggleJoin(_communities[i]),
              ),
            ),
    );
  }
}
