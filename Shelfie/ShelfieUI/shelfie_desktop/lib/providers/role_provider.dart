import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/role.dart';
import 'base_provider.dart';

class RoleProvider extends BaseProvider<Role> {
  RoleProvider() : super("Role");

  @override
  Role fromJson(dynamic json) => Role.fromJson(json);

  @override
  Future<List<Role>> getAll(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Role");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load user roles");
  }

}
