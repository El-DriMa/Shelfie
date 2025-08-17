import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import 'base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(dynamic json) => Review.fromJson(json);

  @override
    Future<List<Review>> getAll(
    String authHeader, {
    String? bookName,
    String? username,
    }) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Review").replace(
        queryParameters: {
        if (bookName != null && bookName.isNotEmpty) 'BookName': bookName,
        if (username != null && username.isNotEmpty) 'Username': username,
        },
    );

    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['items'];
        return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load reviews");
    }


  Future<List<Review>> getByBookId(String authHeader, int bookId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Review?BookId=$bookId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load reviews for book");
  }

  Future<void> addReview(String authHeader, Map<String, dynamic> data) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Review");
    final response = await http.post(
      uri,
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add review');
    }
  }


  Future<void> updateReview(String authHeader, int reviewId, int rating, String description) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Review/$reviewId");
    final response = await http.put(
      uri,
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'rating': rating,
        'description': description,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update review');
    }
  }


  Future<void> delete(String authHeader, int reviewId) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}Review/$reviewId');
    final response = await http.delete(
      uri,
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete review');
    }
  }
}
