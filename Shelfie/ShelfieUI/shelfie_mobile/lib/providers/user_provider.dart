import 'dart:convert';
import 'dart:io';
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

  Future<void> deleteUser(String authHeader, int userId) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}User/$userId');
    final response = await http.delete(
      uri,
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete user');
    }
  }

  Future<void> changePassword(String authHeader, String oldPassword, String newPassword) async {
    final uri = Uri.parse('${BaseProvider.baseUrl}User/change-password');

    final response = await http.post(
      uri,
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print("Password changed successfully");
    } else {
      final message = response.body.isNotEmpty ? jsonDecode(response.body)['title'] ?? response.body : 'Error';
      throw Exception(message);
    }
  }

  Future<void> uploadPhoto(String authHeader, int userId, File photoFile) async {
    try {
      final uri = Uri.parse("${BaseProvider.baseUrl}User/$userId/cover");

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
