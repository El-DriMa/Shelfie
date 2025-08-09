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
}
