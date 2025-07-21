import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shelfie/config.dart';

import '../models/book.dart';
import '../models/shelfBooks.dart';
import '../models/shelf.dart';
import 'book_details_screen.dart';

Future<List<ShelfBooks>> fetchReadShelfBooks(String authHeader,int shelfId) async {
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
class ReadShelfScreen extends StatefulWidget {
  final String authHeader;
  final int shelfId;
  ReadShelfScreen({required this.authHeader,required this.shelfId});

  @override
  State<ReadShelfScreen> createState() => _ReadShelfScreenState();
}




class _ReadShelfScreenState extends State<ReadShelfScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FutureBuilder<List<ShelfBooks>>(
              future: fetchReadShelfBooks(widget.authHeader,widget.shelfId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading read shelf'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No read shelf found'));
                }
                final data = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final book = data[index];
                    Widget imageWidget = Container(
                      color: Colors.grey,
                      height: 150,
                      width: 100,
                      child: Icon(Icons.book, size: 30),
                    );

                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsScreen(
                                authHeader: widget.authHeader,
                                bookId: book.bookId,
                              ),
                            ),
                          );
                        },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageWidget,
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    book.bookTitle ?? 'Unknown Book',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    book.authorName ?? 'Unknown Author',
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
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirm Delete'),
                                              content: Text('Are you sure you want to delete this book from the shelf?'),
                                              actions: [
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(false);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Delete'),
                                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(true);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmed == true) {
                                          await removeBookFromShelf(widget.authHeader, book.id);
                                          await fetchReadShelfBooks(widget.authHeader, book.shelfId);
                                          setState(() {});
                                          //Navigator.pop(context, true);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Book removed from shelf'),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Text('Remove'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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