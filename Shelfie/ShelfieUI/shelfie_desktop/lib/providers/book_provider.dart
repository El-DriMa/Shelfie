import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import 'base_provider.dart';
import 'dart:io';

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


  Future<List<Book>> getForUser(String authHeader, {
    String? title,
    String? genreName,
    String? authorName,
    String? publisherName,
    String? fts,
  }) async {
    final params = <String, String>{};
    
    if (title != null && title.isNotEmpty) params['Title'] = title;
    if (genreName != null && genreName.isNotEmpty) params['GenreName'] = genreName;
    if (authorName != null && authorName.isNotEmpty) params['AuthorName'] = authorName;
    if (publisherName != null && publisherName.isNotEmpty) params['PublisherName'] = publisherName;
    if (fts != null && fts.isNotEmpty) params['FTS'] = fts;

    final uri = Uri.parse('${BaseProvider.baseUrl}Book/user').replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: createHeaders(authHeader),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user books');
    }
  }

  
  Future<List<Book>> advancedSearch(String authHeader, {
    String? title,
    String? genreName,
    String? authorName,
    String? publisherName,
    String? fts,
  }) async {
    final params = <String, String>{};
    
    if (title != null && title.isNotEmpty) params['Title'] = title;
    if (genreName != null && genreName.isNotEmpty) params['GenreName'] = genreName;
    if (authorName != null && authorName.isNotEmpty) params['AuthorName'] = authorName;
    if (publisherName != null && publisherName.isNotEmpty) params['PublisherName'] = publisherName;
    if (fts != null && fts.isNotEmpty) params['FTS'] = fts;

    final uri = Uri.parse('${BaseProvider.baseUrl}Book').replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: createHeaders(authHeader),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }

  
  Future<Book> createBook(String authHeader, Map<String, dynamic> bookData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Book");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(bookData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to create book");
  }

  Future<void> updateBook(String authHeader, int bookId, Map<String, dynamic> bookData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Book/$bookId");
    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(bookData),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update book");
    }
  }

 
  Future<bool> deleteBook(String authHeader, int bookId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Book/$bookId");
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

   Future<void> uploadPhoto(String authHeader, int bookId, File photoFile) async {
    try {
      final uri = Uri.parse("${BaseProvider.baseUrl}Book/$bookId/cover");

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'authorization': authHeader,
      });

      var stream = http.ByteStream(photoFile.openRead());
      var length = await photoFile.length();
      var filename = photoFile.path.split('/').last;

      var multipartFile = http.MultipartFile(
        'coverImage',
        stream,
        length,
        filename: filename,
      );

      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = response.body.isNotEmpty ? response.body : "Upload failed";
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }

}
