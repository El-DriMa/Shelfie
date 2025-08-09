import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

abstract class BaseProvider<T> with ChangeNotifier {
  static String? baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://10.0.2.2:5046/api/",
    );
  }

  Map<String, String> createHeaders(String authHeader) {
    return {
      'authorization': authHeader,
      'content-type': 'application/json',
    };
  }

  Future<List<T>> getAll(String authHeader) async {
    final uri = Uri.parse("$baseUrl$_endpoint");
    final response = await http.get(uri, headers: createHeaders(authHeader));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    } else {
      throw Exception("Failed to load $_endpoint");
    }
  }

  T fromJson(dynamic json);
}
