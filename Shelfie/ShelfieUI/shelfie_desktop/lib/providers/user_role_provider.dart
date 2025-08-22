import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/userRole.dart';
import 'base_provider.dart';

class UserRoleProvider extends BaseProvider<UserRole> {
  UserRoleProvider() : super("UserRole");

  @override
  UserRole fromJson(dynamic json) => UserRole.fromJson(json);

  Future<List<UserRole>> getAllForUser(
    String authHeader, {
    int? userId,
    int? page,
    int? pageSize,
    }) async {
      final uri = Uri.parse("${BaseProvider.baseUrl}UserRole").replace(
        queryParameters: {
          if (userId != null) 'UserId': userId.toString(),
          if (page != null) 'Page': page.toString(),
          if (pageSize != null) 'PageSize': pageSize.toString(),
        },
      );

      final response = await http.get(uri, headers: createHeaders(authHeader));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['items'];
        return items.map((json) => fromJson(json)).toList();
      }

      throw Exception("Failed to load user roles");
    }


  Future<UserRole> createRole(String authHeader, Map<String, dynamic> roleData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}UserRole");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(roleData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to create role");
  }

  Future<UserRole> updateRole(String authHeader, int roleId, Map<String, dynamic> roleData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}UserRole/$roleId");
    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(roleData),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to update role");
  }

  Future<bool> deleteRole(String authHeader, int roleId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}UserRole/$roleId");
    final response = await http.delete(uri, headers: createHeaders(authHeader));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<void> updateUserRoles(String authHeader, int userId, List<String> roles) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}UserRole/$userId/update-roles");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(roles),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = response.body.isNotEmpty ? response.body : "Failed to update user roles";
      throw Exception(message);
    }
  }
}
