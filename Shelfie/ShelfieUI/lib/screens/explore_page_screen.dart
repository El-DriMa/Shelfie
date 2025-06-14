import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import 'package:shelfie/config.dart';

Future<List<Book>> fetchBooks(String authHeader) async {
  //print(' Fetching books from API...');

  final response = await http.get(
    Uri.parse('$baseUrl/Book'),
    headers: {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
  );

  print(' Response status code: ${response.statusCode}');
 // print(' Raw response body: ${response.body}');

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


class ExplorePageScreen extends StatelessWidget {

  final String authHeader;

  ExplorePageScreen({required this.authHeader});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Text('Shelfie',style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text('Search')),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(4),
        child: FutureBuilder<List<Book>>(
          future: fetchBooks(authHeader),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load books'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No books found'));
            }

            final books = snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                Widget imageWidget;
                if (book.coverImageBase64 != null) {
                  imageWidget = Image.memory(
                    base64Decode(book.coverImageBase64!),
                    fit: BoxFit.cover,
                    height: 100,
                    width: 70,
                  );
                } else {
                  imageWidget = Container(
                    color: Colors.white,
                    height: 100,
                    width: 70,
                    child: Icon(Icons.book, size: 40),
                  );
                }

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (book.coverImageBase64 != null)
                            ? Image.memory(
                          base64Decode(book.coverImageBase64!),
                          height: 150,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          height: 150,
                          width: 100,
                          color: Colors.grey,
                          child: Icon(Icons.book, size: 60),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                book.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                book.authorName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 20),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text('Add to Shelf'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}