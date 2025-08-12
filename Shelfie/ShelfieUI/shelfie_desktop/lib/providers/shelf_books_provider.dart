import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shelfBooks.dart';
import 'base_provider.dart';

class ShelfBooksProvider extends BaseProvider<ShelfBooks> {
  ShelfBooksProvider() : super("ShelfBooks");

  @override
  ShelfBooks fromJson(dynamic json) => ShelfBooks.fromJson(json);

  Future<List<ShelfBooks>> getByShelfId(String authHeader, int shelfId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ShelfBooks")
        .replace(queryParameters: {'ShelfId': shelfId.toString()});
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load shelf books");
  }

  Future<ShelfBooks> addToShelf(String authHeader, int bookId, int shelfId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ShelfBooks");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode({
        'bookId': bookId,
        'shelfId': shelfId,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to add book to shelf");
  }

  Future<void> updatePagesRead(String authHeader, int id, int pagesRead) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ShelfBooks/$id");

    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode({'pagesRead': pagesRead}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update pages read');
    }
  }

  Future<ShelfBooks?> removeBookFromShelf(String authHeader, int id) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ShelfBooks/$id");

    final response = await http.delete(
      uri,
      headers: createHeaders(authHeader),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else if (response.statusCode == 204) {
      return null;
    }
    throw Exception("Failed to delete book from shelf");
  }

  @override
  Future<List<ShelfBooks>> getAll(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ShelfBooks");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load shelf books");
  }

  Future<ShelfBooks> updateShelfBook(String authHeader, int shelfBookId, Map<String, dynamic> shelfBookData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ShelfBooks/$shelfBookId");
    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(shelfBookData),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to update shelf book");
  }
}
