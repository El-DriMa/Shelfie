import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';
import 'base_provider.dart';

class CommentProvider extends BaseProvider<Comment> {
  CommentProvider() : super("Comment");

  @override
  Comment fromJson(dynamic json) => Comment.fromJson(json);

  @override
  Future<List<Comment>> getAll(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Comment");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load comments");
  }


  Future<List<Comment>> fetchComments(String authHeader, int postId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Comment/Post/$postId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load comments for post $postId");
  }

  Future<Comment> addComment(String authHeader, int postId, int userId, String content, int? parentCommentId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Comment");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode({
        'postId': postId,
        'userId': userId,
        'content': content,
        'parentCommentId': parentCommentId,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to add new comment");
  }



  Future<Comment> updateComment(String authHeader, int commentId, Map<String, dynamic> commentData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Comment/$commentId");
    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(commentData),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to update comment");
  }

  Future<bool> deleteComment(String authHeader, int commentId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Comment/$commentId");
    final response = await http.delete(uri, headers: createHeaders(authHeader));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<Comment> getById(String authHeader, int commentId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Comment/$commentId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to load comment");
  }
}
