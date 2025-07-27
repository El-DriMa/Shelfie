import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shelfie/config.dart';

import '../models/book.dart';
import '../models/shelfBooks.dart';
import '../models/shelf.dart';
import 'add_to_shelf_screen.dart';
import 'book_details_screen.dart';
import '../utils/api_helpers.dart';
import 'package:intl/intl.dart';

class CurrentlyReadingShelfScreen extends StatefulWidget {
  final String authHeader;
  final int shelfId;
  CurrentlyReadingShelfScreen({required this.authHeader,required this.shelfId});

  @override
  State<CurrentlyReadingShelfScreen> createState() => _CurrentlyReadingShelfScreenState();
}


class _CurrentlyReadingShelfScreenState extends State<CurrentlyReadingShelfScreen> {

  int readShelfId=0;

  @override
  void initState() {
    super.initState();
    fetchReadShelfId();
  }

  Future<void> fetchReadShelfId() async {
    final shelves = await fetchShelves(widget.authHeader);
    final shelf = shelves.firstWhere(
          (shelf) => shelf.name == 'Read',
    );
    setState(() {
      readShelfId = shelf.id;
    });
  }

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
                          child : SizedBox(
                          height: 200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    imageWidget,
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.bookTitle ?? 'Unknown Book',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            book.authorName ?? 'Unknown Author',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            book.pagesRead != null
                                                ? 'Pages Read: ${book.pagesRead}'
                                                : 'Pages Read: 0',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            book.updatedAt != null
                                                ? 'Last Updated: ${DateFormat('dd.MM.yyyy').format(book.updatedAt!)}'
                                                : 'Last Updated: ${DateFormat('dd.MM.yyyy').format(book.createdAt)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Update reading progress',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
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
                                              title: Text('Confirm Move'),
                                              content: Text('Are you sure you want to delete this book from the shelf?'),
                                              actions: [
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(false);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Move'),
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
                                          var bookId = book.bookId;
                                          await removeBookFromShelf(widget.authHeader, book.id);
                                          await addToShelf(widget.authHeader, bookId, readShelfId);
                                          await fetchShelfBooks(widget.authHeader, book.shelfId);
                                          setState(() {});
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Book moved to other shelf'),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Text('Read'),
                                    ),

                                  ],
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