import 'package:flutter/material.dart';

class Post {
  final int postID;
  final int userID;
  final int communityID;
  final String postType;
  final String title;
  final String body;
  final String author;
  final String community;
  final DateTime createdAt;
  final bool isPinned;
  final int viewCount;
  final String? tagList;
  Map<String, int> reactions;

  Post({
    required this.postID,
    required this.userID,
    required this.communityID,
    required this.postType,
    required this.title,
    required this.body,
    required this.author,
    required this.community,
    required this.createdAt,
    this.isPinned = false,
    this.viewCount = 0,
    this.tagList,
    Map<String, int>? reactions,
  }) : reactions = reactions ??
            {
              '👍': 0,
              '❤️': 0,
              '😂': 0,
              '😡': 0,
              '😢': 0,
            };

  factory Post.fromJson(Map<String, dynamic> json) {
    debugPrint("🔍 Parsing Post: $json");

    // Mặc định reactions
    Map<String, int> defaultReactions = {
      '👍': 0,
      '❤️': 0,
      '😂': 0,
      '😡': 0,
      '😢': 0,
    };

    try {
      // Parse reactions nếu API trả
      if (json['reactions'] is Map) {
        (json['reactions'] as Map).forEach((key, value) {
          defaultReactions[key] = int.tryParse(value.toString()) ?? 0;
        });
      }

      final post = Post(
        postID: json['postID'] ?? 0,
        userID: json['userID'] ?? 0,
        communityID: json['communityID'] ?? 0,
        postType: json['postType']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        author: json['author']?.toString() ?? 'Unknown',
        community: json['community']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        isPinned: json['isPinned'] == 1 || json['isPinned'] == true,
        viewCount: int.tryParse(json['viewCount']?.toString() ?? '0') ?? 0,
        tagList: json['tagList']?.toString(),
        reactions: defaultReactions,
      );

      debugPrint(
          "✅ Parsed Post: ${post.postID} - ${post.title} (${post.createdAt.toIso8601String()})");
      return post;
    } catch (e) {
      debugPrint("❌ Lỗi parse Post: $e | Data: $json");
      return Post(
        postID: 0,
        userID: 0,
        communityID: 0,
        postType: '',
        title: '',
        body: '',
        author: '',
        community: '',
        createdAt: DateTime.now(),
        reactions: defaultReactions,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'postID': postID,
      'userID': userID,
      'communityID': communityID,
      'postType': postType,
      'title': title,
      'body': body,
      'tagList': tagList,
      'isPinned': isPinned ? 1 : 0,
      'viewCount': viewCount,
      'author': author,
      'community': community,
      'createdAt': createdAt.toIso8601String(),
      'reactions': reactions,
    };
  }
}
