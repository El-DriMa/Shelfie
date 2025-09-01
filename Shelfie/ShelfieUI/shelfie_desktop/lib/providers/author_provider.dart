import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/author.dart';
import 'base_provider.dart';

class AuthorProvider extends BaseProvider<Author> {
  AuthorProvider() : super("Author");

  @override
  Author fromJson(dynamic json) => Author.fromJson(json);

  @override
  Future<List<Author>> getAll(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Author");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load authors");
  }

  Future<Author> getById(String authHeader, int authorId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Author/$authorId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to load author");
  }

  Future<Author> createAuthor(String authHeader, Map<String, dynamic> authorData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Author");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(authorData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to create author");
  }

    Future<void> updateAuthor(String authHeader, int authorId, Map<String, dynamic> authorData) async {
      final uri = Uri.parse("${BaseProvider.baseUrl}Author/$authorId");
      final response = await http.put(
        uri,
        headers: createHeaders(authHeader),
        body: jsonEncode(authorData),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update author");
      }
    }


 Future<bool> deleteAuthor(String authHeader, int authorId) async {
  final uri = Uri.parse("${BaseProvider.baseUrl}Author/$authorId");
  final response = await http.delete(uri, headers: createHeaders(authHeader));

  if (response.statusCode == 200 || response.statusCode == 204) {
    return true;
  } else {
    String errorMessage = 'Cannot delete author';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded['message'] != null) {
        errorMessage = decoded['message'];
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }
}


  Future<List<Author>> searchAuthors(String authHeader, String query) async {
    final params = <String, String>{};
    if (query.trim().isNotEmpty) {
      params['FTS'] = query;
    }

    final uri = Uri.parse('${BaseProvider.baseUrl}Author').replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: createHeaders(authHeader),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => Author.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search authors');
    }
  }
}
