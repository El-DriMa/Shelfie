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
    final response = await http.get(uri, headers: createHeaders(authHeader));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    } else {
      throw Exception("Failed to load shelves");
    }
  }

  Future<List<Shelf>> fetchShelves(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Shelf");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load shelves");
  }

  Future<Shelf> getById(String authHeader, int shelfId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Shelf/$shelfId");
    final response = await http.get(uri, headers: createHeaders(authHeader));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to load shelf");
  }

  Future<Shelf> createShelf(String authHeader, Map<String, dynamic> shelfData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Shelf");
    final response = await http.post(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(shelfData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to create shelf");
  }

  Future<Shelf> updateShelf(String authHeader, int shelfId, Map<String, dynamic> shelfData) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Shelf/$shelfId");
    final response = await http.put(
      uri,
      headers: createHeaders(authHeader),
      body: jsonEncode(shelfData),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    }
    throw Exception("Failed to update shelf");
  }

  Future<bool> deleteShelf(String authHeader, int shelfId) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Shelf/$shelfId");
    final response = await http.delete(uri, headers: createHeaders(authHeader));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  
}

