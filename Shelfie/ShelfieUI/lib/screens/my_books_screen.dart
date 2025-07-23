import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shelfie/screens/explore_page_screen.dart';
import 'package:shelfie/screens/read_shelf_screen.dart';
import 'package:shelfie/screens/want_to_read_shelf_screen.dart';

import '../models/shelf.dart';
import '../models/book.dart';
import 'package:shelfie/config.dart';

import 'currently_reading_shelf_screen.dart';
import '../utils/api_helpers.dart';

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
                          Widget screen;
                          switch (shelf.name) {
                            case 'Read':
                              screen = ReadShelfScreen(authHeader: widget.authHeader, shelfId: shelf.id);
                              break;
                            case 'WantToRead':
                              screen = WantToReadShelfScreen(authHeader: widget.authHeader, shelfId: shelf.id);
                              break;
                            case 'CurrentlyReading':
                              screen = CurrentlyReadingShelfScreen(authHeader: widget.authHeader, shelfId: shelf.id);
                              break;
                            default:
                              screen = ExplorePageScreen(authHeader: widget.authHeader);

                          }

                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => screen),
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