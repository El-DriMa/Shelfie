import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import 'base_provider.dart';

class BookProvider extends BaseProvider<Book> {
  BookProvider() : super("Book");

  @override
  Book fromJson(dynamic json) => Book.fromJson(json);

  @override
  Future<List<Book>> getAll(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Book");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load books");
  }

  Future<List<Book>> getRecommended(String authHeader, int userId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Book/recommended/$userId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load recommended books");
  }

  Future<Book> getById(String authHeader, int bookId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Book/$bookId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to load book");
  }

  Future<List<Book>> searchBooks(String authHeader, String query) async {
    final params = <String, String>{};
    if (query.trim().isNotEmpty) {
      params['Title'] = query;
    }

    final uri = Uri.parse('${BaseProvider.baseUrl}Book').replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }
}
