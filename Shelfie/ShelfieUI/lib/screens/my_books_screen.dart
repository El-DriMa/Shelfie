import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shelfie/screens/read_shelf_screen.dart';

import '../models/shelf.dart';
import '../models/book.dart';
import 'package:shelfie/config.dart';

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

class MyBooksScreen extends StatefulWidget {
  final String authHeader;

  MyBooksScreen({required this.authHeader});

  @override
  _MyBooksScreenState createState() => _MyBooksScreenState();
}


class _MyBooksScreenState extends State<MyBooksScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Books'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 24.0, bottom: 12.0),
            child: Center(
              child: Text(
                "SHELVES",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(
              color: Colors.black,
              thickness: 2,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Shelf>>(
              future: fetchShelves(widget.authHeader),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading shelves'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No shelves found'));
                }
                final shelves = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: shelves.length,
                  itemBuilder: (context, index) {
                    final shelf = shelves[index];
                    Widget imageWidget = Container(
                      color: Colors.grey,
                      height: 100,
                      width: 80,
                      child: Icon(Icons.book, size: 30),
                    );

                    return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadShelfScreen(
                                authHeader: widget.authHeader,
                                shelfId: shelf.id,
                              ),
                            ),
                          );

                          if (result == true) {
                            await fetchShelves(widget.authHeader);

                          }
                        },
                        child: Card(
                      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ // FIX: wrap children of Row in a list
                            imageWidget,
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    prettifyShelfName(shelf.name),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${shelf.booksCount} books',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}