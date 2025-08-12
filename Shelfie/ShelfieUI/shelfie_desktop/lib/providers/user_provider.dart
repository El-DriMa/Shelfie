import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'base_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  @override
  User fromJson(dynamic json) => User.fromJson(json);

  Future<User> getCurrentUser(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}User/me");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to load current user");
  }

  Future<void> updateUser(String authHeader, int id, Map<String, dynamic> data) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}User/$id");
    final response = await http.put(
      uri,
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update user');
    }
  }

  @override
  Future<List<User>> getAll(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}User");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load users");
  }

  Future<User> getById(String authHeader, int userId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}User/$userId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to load user");
  }

  Future<User> createUser(String authHeader, Map<String, dynamic> userData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}User");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(userData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to create user");
  }

  Future<User> updateUserById(String authHeader, int userId, Map<String, dynamic> userData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}User/$userId");
    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(userData),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to update user");
  }

  Future<bool> deleteUser(String authHeader, int userId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}User/$userId");
    final response = await http.delete(uri, headers: createHeaders(authHeader));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<List<User>> searchUsers(String authHeader, String query) async {
    final params = <String, String>{};
    if (query.isNotEmpty) params['FTS'] = query;

    final uri = Uri.parse("${BaseProvider.baseUrl}User").replace(queryParameters: params);
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to search users");
  }
}
