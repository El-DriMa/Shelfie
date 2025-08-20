import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import 'base_provider.dart';

class PostProvider extends BaseProvider<Post> {
  PostProvider() : super("Post");

  @override
  Post fromJson(dynamic json) => Post.fromJson(json);

  Future<List<Post>> getByGenre(String authHeader, int genreId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Post/Genre/$genreId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load posts by genre");
  }

  Future<List<Post>> getUserPosts(String authHeader, int genreId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Post/user/$genreId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load user posts");
  }

  Future<Post> getById(String authHeader, int postId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Post/$postId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to load post");
  }

  Future<Post> addNewPost(String authHeader, String content, int userId, int genreId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Post");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode({
        'content': content,
        'userId': userId,
        'genreId': genreId,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to add new Post");
  }

  Future<void> updatePostState(String authHeader, int postId, int newState) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Post/$postId");
    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode({'state': newState}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update post state');
    }
  }

  Future<Post> updatePost(String authHeader, int postId, Map<String, dynamic> postData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Post/$postId");
    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(postData),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to update post");
  }

  Future<bool> deletePost(String authHeader, int postId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Post/$postId");
    final response = await http.delete(uri, headers: createHeaders(authHeader));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<List<Post>> getAll(
    String authHeader, {
    String? username,
    int? postState,
    String? genreName,
  }) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Post").replace(
      queryParameters: {
        if (username != null && username.isNotEmpty) 'Username': username,
        if (postState != null) 'PostState': postState.toString(),
        if (genreName != null && genreName.isNotEmpty) 'GenreName': genreName,
      },
    );

    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load posts");
  }

}
