import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shelfie/config.dart';

import '../models/book.dart';
import '../models/shelfBooks.dart';
import '../models/shelf.dart';
import 'book_details_screen.dart';
import '../utils/api_helpers.dart';

class CurrentlyReadingShelfScreen extends StatefulWidget {
  final String authHeader;
  final int shelfId;
  CurrentlyReadingShelfScreen({required this.authHeader,required this.shelfId});

  @override
  State<CurrentlyReadingShelfScreen> createState() => _CurrentlyReadingShelfScreenState();
}




class _CurrentlyReadingShelfScreenState extends State<CurrentlyReadingShelfScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currently Reading'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FutureBuilder<List<ShelfBooks>>(
              future: fetchShelfBooks(widget.authHeader,widget.shelfId),
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
                                            await fetchShelfBooks(widget.authHeader, book.shelfId);
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