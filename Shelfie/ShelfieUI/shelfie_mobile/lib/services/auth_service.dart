import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  Future<String?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/User/me');
    final basicAuth = 'Basic ${base64Encode(utf8.encode('$email:$password'))}';
    print("Logging in with URL: $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': basicAuth,
        'X-App-Type': 'mobile',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

       if (data['id'] == -1 && data['username'] == "FORBIDDEN") {
        return "FORBIDDEN";
      }

      final roles = (data['roles'] as List<dynamic>).map((r) => r.toString()).toList();

      if (roles.contains('User')) {
        return basicAuth; 
      } else {
        return null; 
      }
    } else if (response.statusCode == 401) {
      throw Exception('Invalid credentials');
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }
}
