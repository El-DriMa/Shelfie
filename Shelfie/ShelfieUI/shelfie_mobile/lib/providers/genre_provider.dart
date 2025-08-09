import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/genre.dart';
import 'base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  @override
  Genre fromJson(dynamic json) => Genre.fromJson(json);

  Future<List<Genre>> fetchGenres(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Genre");
    final response = await http.get(uri, headers: createHeaders(authHeader));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load genres");
  }

  Future<List<Genre>> searchGenres(String authHeader, String query) async {
    final params = <String, String>{};
    if (query.trim().isNotEmpty) {
      params['Name'] = query;
    }

    final uri = Uri.parse("${BaseProvider.baseUrl}Genre")
        .replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: createHeaders(authHeader),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    } else {
      throw Exception('Failed to search genre');
    }
  }
}

