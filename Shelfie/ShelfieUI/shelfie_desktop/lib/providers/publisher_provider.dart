import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/publisher.dart';
import 'base_provider.dart';

class PublisherProvider extends BaseProvider<Publisher> {
  PublisherProvider() : super("Publisher");

  @override
  Publisher fromJson(dynamic json) => Publisher.fromJson(json);

  @override
  Future<List<Publisher>> getAll(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Publisher");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load publishers");
  }

  Future<Publisher> getById(String authHeader, int publisherId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Publisher/$publisherId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to load publisher");
  }

  Future<Publisher> createPublisher(String authHeader, Map<String, dynamic> publisherData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Publisher");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(publisherData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to create publisher");
  }

  Future<void> updatePublisher(String authHeader, int publisherId, Map<String, dynamic> publisherData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Publisher/$publisherId");
    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(publisherData),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update publisher");
    }
  }


  Future<bool> deletePublisher(String authHeader, int publisherId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Publisher/$publisherId");
    final response = await http.delete(uri, headers: createHeaders(authHeader));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<List<Publisher>> searchPublishers(String authHeader, String query) async {
    final params = <String, String>{};
    if (query.trim().isNotEmpty) {
      params['FTS'] = query;
    }

    final uri = Uri.parse('${BaseProvider.baseUrl}Publisher').replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: createHeaders(authHeader),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => Publisher.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search publishers');
    }
  }
}
