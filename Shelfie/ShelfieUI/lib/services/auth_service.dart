import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/User/me');

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$email:$password'))}';

    final response = await http.get(
      url,
      headers: {'authorization': basicAuth},
    );

    return response.statusCode == 200;
  }
}