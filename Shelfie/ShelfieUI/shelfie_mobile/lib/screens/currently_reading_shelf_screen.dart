import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:http/http.dart' as http;
import 'package:shelfie/config.dart';

import '../config.dart' as BaseProvider;
import '../models/shelfBooks.dart';
import '../providers/shelf_books_provider.dart';
import '../providers/shelf_provider.dart';
import 'book_details_screen.dart';
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
  String _sortBy = 'Date Added';
  List<ShelfBooks> sortedBooks = [];

  final _shelfProvider = ShelfProvider();
  final _shelfBooksProvider = ShelfBooksProvider();

  @override
  void initState() {
    super.initState();
    fetchReadShelfId();
  }

  Future<void> fetchReadShelfId() async {
    final shelves = await _shelfProvider.getAll(widget.authHeader);
    final shelf = shelves.firstWhere(
          (shelf) => shelf.name == 'Read',
    );
    setState(() {
      readShelfId = shelf.id;
    });
  }

  String? _getImageUrl(String photoUrl) {
    if (photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) return photoUrl;

    String base = BaseProvider.baseUrl ?? '';
    base = base.replaceAll(RegExp(r'/api/?$'), '');

    return '$base/$photoUrl';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currently Reading'),
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
              future: _shelfBooksProvider.getByShelfId(widget.authHeader,widget.shelfId),
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
                    final imageUrl = _getImageUrl(book.photoUrl ?? '');
                    Widget imageWidget;
                    if (book.photoUrl != null && book.photoUrl!.isNotEmpty) {
                      imageWidget = Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        width: 100,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.white54,
                          height: 160,
                          width: 100,
                          child: Icon(Icons.menu_book_rounded, size: 60),
                        ),
                      );
                    } else {
                      imageWidget = Container(
                        color: Colors.white54,
                        height: 160,
                        width: 100,
                        child: Icon(Icons.menu_book_rounded, size: 60),
                      );
                    }

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
                          height: 210,
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
                                                ? 'Pages Read: ${book.pagesRead}/${book.totalPages}'
                                                : 'Pages Read: 0/${book.totalPages}',
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
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              RatingBarIndicator(
                                                rating: book.averageRating ?? 0,
                                                itemBuilder: (context, _) => Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                itemCount: 5,
                                                itemSize: 20,
                                                direction: Axis.horizontal,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                (book.averageRating ?? 0).toStringAsFixed(1),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final currentPagesRead = book.pagesRead ?? 0;
                                        final newPagesRead = await showDialog<int>(
                                          context: context,
                                          builder: (context) {
                                            int tempPagesRead = currentPagesRead;
                                            return AlertDialog(
                                              title: Text('Update your reading progress'),
                                              content: TextFormField(
                                                initialValue: tempPagesRead.toString(),
                                                keyboardType: TextInputType.number,
                                                onChanged: (val) {
                                                  tempPagesRead = int.tryParse(val) ?? 0;
                                                },
                                                decoration: InputDecoration(
                                                  labelText: 'Pages Read',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () => Navigator.of(context).pop(null),
                                                ),
                                                ElevatedButton(
                                                  child: Text('Save'),
                                                  onPressed: () => Navigator.of(context).pop(tempPagesRead),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (newPagesRead != null && newPagesRead != currentPagesRead) {
                                          try {
                                            await _shelfBooksProvider.updatePagesRead(widget.authHeader,book.id, newPagesRead);
                                            setState(() {});
                                          } catch (e) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                               // title: Text('Error'),
                                                content: Text('Pages read cannot be decreased or exceed the total number of pages.'),
                                                actions: [
                                                  TextButton(
                                                    child: Text('OK'),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Text(
                                        'Update reading progress',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
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
                                          await _shelfBooksProvider.removeBookFromShelf(widget.authHeader, book.id);
                                          await _shelfBooksProvider.addToShelf(widget.authHeader, bookId, readShelfId);
                                          await _shelfBooksProvider.getByShelfId(widget.authHeader, book.shelfId);
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