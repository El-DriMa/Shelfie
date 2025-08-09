import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/shelf.dart';
import 'base_provider.dart';

class ShelfProvider extends BaseProvider<Shelf> {
  ShelfProvider() : super("Shelf");

  @override
  Shelf fromJson(dynamic json) {
    return Shelf.fromJson(json);
  }

  @override
  Future<List<Shelf>> getAll(String authHeader) async {

    final uri = Uri.parse("${BaseProvider.baseUrl}Shelf/user");
    print("Pozivam GET na: $uri");
    print("Headers: ${createHeaders(authHeader)}");

    final response = await http.get(uri, headers: createHeaders(authHeader));

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    } else {
      throw Exception("Failed to load shelves");
    }
  }

}

