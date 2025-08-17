import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/readingChallenge.dart';
import 'base_provider.dart';
import 'package:intl/intl.dart';

class ReadingChallengeProvider extends BaseProvider<ReadingChallenge> {
  ReadingChallengeProvider() : super("ReadingChallenge");

  @override
  ReadingChallenge fromJson(dynamic json) => ReadingChallenge.fromJson(json);

  Future<List<ReadingChallenge>> getUserChallenges(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ReadingChallenge/user");
    final response = await http.get(uri, headers: createHeaders(authHeader));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load user challenges");
  }

  Future<ReadingChallenge> getById(String authHeader, int challengeId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ReadingChallenge/$challengeId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to load ReadingChallenge details");
  }

  Future<ReadingChallenge> addChallenge(
      String authHeader,
      int userId,
      String challengeName,
      String description,
      int goalType,
      int goalAmount,
      DateTime startDate,
      DateTime endDate,
      int progress,
      bool isCompleted,
      ) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ReadingChallenge");
    final body = jsonEncode({
      'userId': userId,
      'challengeName': challengeName,
      'description': description,
      'goalType': goalType,
      'goalAmount': goalAmount,
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      'progress': progress,
      'isCompleted': isCompleted,
    });
    final response = await http.post(uri, headers: createHeaders(authHeader), body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to add new challenge");
  }

  Future<ReadingChallenge?> deleteChallenge(String authHeader, int id) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ReadingChallenge/$id");
    final response = await http.delete(uri, headers: createHeaders(authHeader));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return fromJson(json);
    } else if (response.statusCode == 204) {
      return null;
    }
    throw Exception("Failed to delete challenge");
  }

  Future<void> updateChallenge(String authHeader, int id, Map<String, dynamic> data) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}ReadingChallenge/$id");

    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Failed to update challenge");
    }
  }

  @override
    Future<List<ReadingChallenge>> getAll(String authHeader, {String? username}) async {
    final query = username != null ? '?Username=$username' : '';
    final uri = Uri.parse("${BaseProvider.baseUrl}ReadingChallenge$query");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => ReadingChallenge.fromJson(json)).toList();
    }
    throw Exception("Failed to load reading challenges");
  }
}
