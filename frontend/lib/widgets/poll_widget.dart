import 'package:flutter/material.dart';
import '../models/poll.dart';
import '../models/user.dart';
import '../services/poll_service.dart';

class PollWidget extends StatefulWidget {
  final int postID;
  final User currentUser;

  const PollWidget({
    super.key,
    required this.postID,
    required this.currentUser,
  });

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  Poll? _poll;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPoll();
  }

  Future<void> _loadPoll() async {
    try {
      final poll = await PollService.getPollByPostId(widget.postID);
      setState(() {
        _poll = poll;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải poll: $e';
        _loading = false;
      });
    }
  }

  Future<void> _vote(int optionID) async {
    if (_poll == null) return;

    try {
      await PollService.vote(
        _poll!.pollID,
        optionID,
        widget.currentUser.userID,
      );

      // Update local ngay lập tức
      setState(() {
        final option = _poll!.options.firstWhere((o) => o.id == optionID);
        option.votes += 1;
        _poll!.voterMap[widget.currentUser.userID] = optionID;
      });

      // Background refresh để đồng bộ
      _loadPoll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi vote: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const CircularProgressIndicator();
    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: Colors.red));
    }
    if (_poll == null || _poll!.options.isEmpty) {
      return const Text('Không có poll khả dụng');
    }

    final totalVotes = _poll!.options.fold<int>(0, (sum, o) => sum + o.votes);
    final votedOptionID = _poll!.voterMap[widget.currentUser.userID];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _poll!.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ..._poll!.options.map((o) {
            final pct =
                totalVotes == 0 ? 0 : (o.votes / totalVotes * 100).round();
            final isSelected = votedOptionID == o.id;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: votedOptionID == null ? () => _vote(o.id) : null,
                  child: Row(
                    children: [
                      Radio<int>(
                        value: o.id,
                        groupValue: votedOptionID,
                        onChanged: votedOptionID == null
                            ? (_) => _vote(o.id)
                            : null,
                        activeColor: Colors.greenAccent,
                      ),
                      Expanded(
                        child: Text(
                          o.text,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.greenAccent
                                : Colors.white70,
                          ),
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.greenAccent
                              : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: totalVotes == 0 ? 0 : o.votes / totalVotes,
                  minHeight: 6,
                  color: isSelected ? Colors.greenAccent : Colors.blueAccent,
                  backgroundColor: Colors.white10,
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
          const SizedBox(height: 4),
          Text(
            'Tổng số phiếu: $totalVotes',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
