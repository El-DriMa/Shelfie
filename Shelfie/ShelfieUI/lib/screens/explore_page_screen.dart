import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shelfie/screens/add_to_shelf_screen.dart';

import '../models/book.dart';
import 'book_details_screen.dart';
import 'package:shelfie/config.dart';
import '../utils/api_helpers.dart';

class ExplorePageScreen extends StatefulWidget {
  final String authHeader;
  ExplorePageScreen({required this.authHeader});

  @override
  State<ExplorePageScreen> createState() => _ExplorePageScreenState();
}

class _ExplorePageScreenState extends State<ExplorePageScreen>{
  late Future<List<Book>> booksFuture;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  void _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      booksFuture = fetchBooks(widget.authHeader);
    });
  }

  void _onSearchSubmitted(String query) {
    print('Search called with query: $query');
    setState(() {
      if (query.trim().isEmpty) {
        booksFuture = fetchBooks(widget.authHeader);
      } else {
        booksFuture = searchBooks(query);

      print('Search result for: $query, result: $booksFuture');

      }
    });
  }

  @override
  void initState() {
    super.initState();
    booksFuture = fetchBooks(widget.authHeader);
  }

  Future<List<Book>> searchBooks(String query) async {
    final params = <String, String>{};
    if (query.trim().isNotEmpty) {
      params['Title'] = query;
    }

    final uri = Uri.parse('$baseUrl/Book').replace(queryParameters: params);
    print('Search request URL: $uri');
    final response = await http.get(
      uri,
      headers: {
        'authorization': widget.authHeader,
        'content-type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }

 void _showSearchDialog() async {
    String query = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Books'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Type anything...'),
            onChanged: (v) => query = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, query),
              child: Text('Search'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        booksFuture = searchBooks(result);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: isSearching
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Title...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white38),

          ),
          style: TextStyle(color: Colors.white),
          onSubmitted: _onSearchSubmitted,
        )
            : Text('Shelfie', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        actions: isSearching
            ? [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: _stopSearch,
          ),
        ]
            : [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text('Search by title',  style: TextStyle(fontSize: 12, color: Colors.grey))),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _startSearch,
          ),

        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(4),
        child: FutureBuilder<List<Book>>(
          future: booksFuture,
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
                if (book.CoverImage != null && book.CoverImage!.isNotEmpty) {
                  imageWidget = Image.network(
                    '$baseUrl/${book.CoverImage}',
                    fit: BoxFit.cover,
                    width: 100,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      height: 150,
                      width: 100,
                      child: Icon(Icons.book, size: 60),
                    ),
                  );
                } else {
                  imageWidget = Container(
                    color: Colors.grey,
                    height: 150,
                    width: 100,
                    child: Icon(Icons.book, size: 60),
                  );
                }

                return GestureDetector(
                    onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailsScreen(
                        authHeader: widget.authHeader,
                        bookId: book.id,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (context) => AddToShelfScreen(
                                      authHeader: widget.authHeader,
                                      bookId: book.id,
                                    ),
                                    ));
                                  },
                                  child: Text('Add to Shelf'),
                                ),
                              ),
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
    );
  }
}