import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/community.dart';
import '../services/post_service.dart';
import '../services/community_service.dart';
import '../services/incident_service.dart';
import '../services/poll_service.dart';

class CreatePostScreen extends StatefulWidget {
  final User currentUser;

  const CreatePostScreen({super.key, required this.currentUser});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Poll options
  final List<TextEditingController> _pollOptionCtrls = [
    TextEditingController(),
    TextEditingController()
  ];

  String _selectedType = 'feed';
  String _severity = 'low';
  bool _submitting = false;

  List<Community> _joinedCommunities = [];
  Community? _selectedCommunity;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    final communities = await CommunityService.getAllCommunities(widget.currentUser.userID);
    setState(() {
      _joinedCommunities = communities.where((c) => c.joined).toList();
      if (_joinedCommunities.isNotEmpty) {
        _selectedCommunity = _joinedCommunities.first;
      }
    });
  }

  void _addPollOption() {
    setState(() {
      _pollOptionCtrls.add(TextEditingController());
    });
  }

  Future<void> _submitPost() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty || _selectedCommunity == null) return;

    setState(() => _submitting = true);

    try {
      // Tạo Post
      final post = Post(
        postID: 0,
        userID: widget.currentUser.userID,
        communityID: _selectedCommunity!.communityID,
        postType: _selectedType,
        title: title,
        body: body,
        author: widget.currentUser.name,
        community: _selectedCommunity!.name,
        createdAt: DateTime.now(),
      );

      final createdPostID = await PostService().createPost(post);

      // Nếu là Incident
      if (_selectedType == 'incident') {
        await IncidentService.createIncident({
          'postID': createdPostID,
          'openedBy': widget.currentUser.userID,
          'severity': _severity,
          'location': _locationCtrl.text.trim(),
          'status': 'open'
        });
      }

      // Nếu là Poll
      if (_selectedType == 'poll') {
        final options = _pollOptionCtrls
            .map((ctrl) => ctrl.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        if (options.length < 2) {
          throw Exception('Poll phải có ít nhất 2 lựa chọn');
        }

        await PollService.createPoll({
          'postID': createdPostID,
          'title': title,
          'options': options
              .asMap()
              .entries
              .map((e) => {'id': e.key + 1, 'text': e.value, 'votes': 0})
              .toList(),
          'duration': 7, // ngày
        });
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng bài: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo bài viết mới')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Chọn loại bài viết
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'feed', child: Text('Thảo luận')),
                DropdownMenuItem(value: 'poll', child: Text('Bình chọn')),
                DropdownMenuItem(value: 'incident', child: Text('Sự cố')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
              decoration: const InputDecoration(labelText: 'Loại bài viết'),
            ),
            const SizedBox(height: 12),

            // Chọn cộng đồng
            DropdownButtonFormField<Community>(
              value: _selectedCommunity,
              items: _joinedCommunities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCommunity = val);
              },
              decoration: const InputDecoration(labelText: 'Chọn cộng đồng'),
            ),
            const SizedBox(height: 12),

            // Nếu là incident
            if (_selectedType == 'incident') ...[
              DropdownButtonFormField<String>(
                value: _severity,
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _severity = val);
                },
                decoration: const InputDecoration(labelText: 'Mức độ sự cố'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Vị trí sự cố'),
              ),
              const SizedBox(height: 12),
            ],

            // Nếu là poll
            if (_selectedType == 'poll') ...[
              const Text('Các lựa chọn bình chọn:'),
              const SizedBox(height: 8),
              ..._pollOptionCtrls.map((ctrl) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Lựa chọn',
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addPollOption,
                icon: const Icon(Icons.add),
                label: const Text('Thêm lựa chọn'),
              ),
              const SizedBox(height: 12),
            ],

            // Tiêu đề
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 12),

            // Nội dung
            Expanded(
              child: TextField(
                controller: _bodyCtrl,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nút đăng bài
            ElevatedButton(
              onPressed: _submitting ? null : _submitPost,
              child: _submitting
                  ? const CircularProgressIndicator()
                  : const Text('Đăng bài'),
            )
          ],
        ),
      ),
    );
  }
}
