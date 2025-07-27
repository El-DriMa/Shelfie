import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelfie/config.dart';

import '../models/book.dart';
import '../models/shelf.dart';
import '../models/shelfBooks.dart';


Future<List<Shelf>> fetchShelves(String authHeader) async {


  final response = await http.get(
    Uri.parse('$baseUrl/Shelf/user'),
    headers: {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
  );

  print(' Response status code: ${response.statusCode}');


  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);
      final List items = data['items'];

      if (items.isEmpty) {
        print('Shelves list is empty.');
      } else {
        print('Loaded ${items.length} shelves.');
        print('First shelf: ${items[0]}');
      }

      return items.map((json) => Shelf.fromJson(json)).toList();
    } catch (e) {
      print('JSON parsing error: $e');
      throw Exception('Error processing data');
    }
  } else {
    print('API call failed. Status code: ${response.statusCode}');
    throw Exception('Failed to load books');
  }
}

Future<List<ShelfBooks>> fetchShelfBooks(String authHeader,int shelfId) async {
  final params = <String, String>{};
  if (shelfId>0) {
    params['ShelfId'] = shelfId.toString();
  }

  final uri = Uri.parse('$baseUrl/ShelfBooks').replace(queryParameters: params);
  print('Search request URL: $uri');
  final response = await http.get(
    uri,
    headers: {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List items = data['items'];
    return items.map((json) => ShelfBooks.fromJson(json)).toList();
  } else {
    throw Exception('Failed to search shelf books');
  }
}

Future<List<Book>> fetchBooks(String authHeader) async {


  final response = await http.get(
    Uri.parse('$baseUrl/Book'),
    headers: {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
  );

  print(' Response status code: ${response.statusCode}');


  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);
      final List items = data['items'];

      if (items.isEmpty) {
        print('Book list is empty.');
      } else {
        print('Loaded ${items.length} books.');
        print('First book: ${items[0]}');
      }

      return items.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('JSON parsing error: $e');
      throw Exception('Error processing data');
    }
  } else {
    print('API call failed. Status code: ${response.statusCode}');
    throw Exception('Failed to load books');
  }
}


Future<Book> fetchBook(String authHeader,int bookId) async {
  final response= await http.get(
      Uri.parse('$baseUrl/Book/$bookId'),
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      }
  );
  print(' Response status code: ${response.statusCode}');
  if (response.statusCode == 200) {
    try {
      final book = jsonDecode(response.body);
      return Book.fromJson(book);
    } catch (e) {
      print('JSON parsing error: $e');
      throw Exception('Error processing data');
    }
  } else {
    print('API call failed. Status code: ${response.statusCode}');
    throw Exception('Failed to load book details');
  }
}

Future<Book> fetchBookDetails(String authHeader,int id) async {
  final response= await http.get(
      Uri.parse('$baseUrl/Book/$id'),
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      }
  );
  print(' Response status code: ${response.statusCode}');
  if (response.statusCode == 200) {
    try {
      final book = jsonDecode(response.body);
      return Book.fromJson(book);
    } catch (e) {
      print('JSON parsing error: $e');
      throw Exception('Error processing data');
    }
  } else {
    print('API call failed. Status code: ${response.statusCode}');
    throw Exception('Failed to load book details');
  }
}

Future<ShelfBooks?> removeBookFromShelf(String authHeader, int id) async {
  final uri = Uri.parse('$baseUrl/ShelfBooks/$id');
  print('DELETE request URL: $uri');

  final response = await http.delete(
    uri,
    headers: {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return ShelfBooks.fromJson(json);
  } else if (response.statusCode == 204) {
    return null;
  } else {
    throw Exception('Failed to delete book from shelf: ${response.statusCode}');
  }
}

String prettifyShelfName(String rawName) {
  switch (rawName) {
    case 'CurrentlyReading':
      return 'Currently Reading';
    case 'WantToRead':
      return 'Want to Read';
    case 'Read':
      return 'Read';
    default:
      return rawName.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
        return '${match.group(1)} ${match.group(2)}';
      });
  }
}
