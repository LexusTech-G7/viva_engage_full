import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostService {
  final String baseUrl = 'http://localhost:3000/api/posts';

  // Lấy tất cả post của user dựa trên các community đã join
  Future<List<Post>> fetchPostsForUser(int userID) async {
    try {
      final url = Uri.parse('$baseUrl/user/$userID');
      final response = await http.get(url);

      print('📡 [GET] $url');
      print('🔍 Status: ${response.statusCode}');
      print('📄 Raw Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        print('📊 Số lượng posts nhận được từ API: ${data.length}');
        final posts = <Post>[];

        for (var item in data) {
          print('🔍 Đang parse Post JSON: $item');
          try {
            final post = Post.fromJson(item);
            print('✅ Parsed thành công: ${post.postID} - ${post.title}');
            posts.add(post);
          } catch (e) {
            print('⚠️ Lỗi parse Post: $e | Data: $item');
          }
        }

        return posts;
      } else {
        print('❌ API trả về lỗi: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('⚠️ fetchPostsForUser exception: $e');
      return [];
    }
  }

  // Tạo post mới và trả về postID
  Future<int> createPost(Post post) async {
    final url = Uri.parse(baseUrl);

    final bodyData = post.toJson();
    print('📡 [POST] $url');
    print('📤 Data: $bodyData');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyData),
    );

    print('🔍 Status: ${response.statusCode}');
    print('📄 Response: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['postID'];
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<Post> fetchPostByID(int postID) async {
    final res = await http.get(Uri.parse('$baseUrl/$postID'));
    if (res.statusCode == 200) {
      return Post.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Không tải được bài viết');
    }
  }
}
