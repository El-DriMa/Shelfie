import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../config.dart' as BaseProvider;
import '../models/shelfBooks.dart';
import '../providers/shelf_books_provider.dart';
import '../providers/shelf_provider.dart';
import 'book_details_screen.dart';

class WantToReadShelfScreen extends StatefulWidget {
  final String authHeader;
  final int shelfId;
  WantToReadShelfScreen({required this.authHeader,required this.shelfId});


  @override
  State<WantToReadShelfScreen> createState() => _WantToReadShelfScreenState();
}


class _WantToReadShelfScreenState extends State<WantToReadShelfScreen> {

  int currentlyReadingShelfId=0;
  String _sortBy = 'Date Added';
  List<ShelfBooks> sortedBooks = [];

  final _shelfBooksProvider = ShelfBooksProvider();
  final _shelfProvider = ShelfProvider();

  @override
  void initState() {
    super.initState();
    fetchCurrentlyReadingShelfId();
  }

  Future<void> fetchCurrentlyReadingShelfId() async {
    final shelves = await _shelfProvider.getAll(widget.authHeader);
    final shelf = shelves.firstWhere(
          (shelf) => shelf.name == 'CurrentlyReading',
    );
    setState(() {
      currentlyReadingShelfId = shelf.id;
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
        title: Text('Want to read'),
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
                          height: 180,
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
                                                title: Text('Confirm Move'),
                                                content: Text('Are you sure you want to move this book to other shelf?'),
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
                                              await _shelfBooksProvider.addToShelf(widget.authHeader,bookId,currentlyReadingShelfId);
                                              await _shelfBooksProvider.getByShelfId(widget.authHeader, book.shelfId);
                                              setState(() {});
                                              //Navigator.pop(context, true);
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
                                          child: Text('Currently Reading'),
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