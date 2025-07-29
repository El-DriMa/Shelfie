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


class ReadShelfScreen extends StatefulWidget {
  final String authHeader;
  final int shelfId;
  ReadShelfScreen({required this.authHeader,required this.shelfId});

  @override
  State<ReadShelfScreen> createState() => _ReadShelfScreenState();
}




class _ReadShelfScreenState extends State<ReadShelfScreen> {

  String _sortBy = 'Date Added';
  List<ShelfBooks> sortedBooks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30, top: 16),
            child : Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _sortBy = value;
                  });
                },
                child: Text(
                  'Sort by: $_sortBy',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'Author', child: Text('Author')),
                  PopupMenuItem(value: 'Alphabetical', child: Text('Alphabetical')),
                  PopupMenuItem(value: 'Date Added', child: Text('Date Added')),
                ],
              ),
            ),
          ),
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

                sortedBooks = List.from(data);
                if (_sortBy == 'Author') {
                  sortedBooks.sort((a, b) => (a.authorName ?? '').compareTo(b.authorName ?? ''));
                } else if (_sortBy == 'Alphabetical') {
                  sortedBooks.sort((a, b) => (a.bookTitle ?? '').compareTo(b.bookTitle ?? ''));
                } else if (_sortBy == 'Date Added') {
                  sortedBooks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: sortedBooks.length,
                  itemBuilder: (context, index) {
                    final book = sortedBooks[index];
                    Widget imageWidget = Container(
                      color: Colors.white54,
                      height: 150,
                      width: 100,
                      child: Icon(Icons.menu_book_rounded, size: 30),
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
                      color: Colors.deepPurple[100],
                      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child : SizedBox(
                        height: 150,
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
                                      color: Colors.white54,
                                    ),
                                  ),
                                Spacer(),
                                Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
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
                                ],
                                ),

                                ],
                              ),
                            ),
                          ],
                        ),
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