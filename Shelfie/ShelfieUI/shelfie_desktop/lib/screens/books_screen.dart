import 'package:flutter/material.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config.dart';
import '../providers/base_provider.dart';
import 'add_edit_book_screen.dart';

class BooksScreen extends StatefulWidget {
  final String authHeader;

  BooksScreen({required this.authHeader});

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final BookProvider _bookProvider = BookProvider();
  List<Book> _books = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortOrder = 'A-Z';


  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      var books = await _bookProvider.getAll(widget.authHeader);
      setState(() {
        _books = books;
        _sortBooks();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

   String? _getImageUrl(String photoUrl) {
    if (photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) return photoUrl;

    String base = BaseProvider.baseUrl ?? '';
    base = base.replaceAll(RegExp(r'/api/?$'), '');

    return '$base/$photoUrl';
  }

  void _sortBooks() {
    if (_sortOrder == 'A-Z') {
      _books.sort((a, b) => a.title.compareTo(b.title));
    } else {
      _books.sort((a, b) => b.title.compareTo(a.title));
    }
  }

  Future<void> _searchBooks(String query) async {
    setState(() => _isLoading = true);
    try {
      var books = await _bookProvider.searchBooks(widget.authHeader, query);
      setState(() {
        _books = books;
        _isLoading = false;
        _currentPage = 1; 
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_books.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage < _books.length)
        ? _currentPage * _itemsPerPage
        : _books.length;
    final pageBooks = _books.sublist(startIndex, endIndex);


   
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Books'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Book title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _searchBooks(value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: _sortOrder,
                      items: const [
                        DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                        DropdownMenuItem(value: 'Z-A', child: Text('Z-A')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortOrder = value!;
                          _sortBooks();
                          _currentPage = 1;
                        });
                      },
                      dropdownColor: Colors.deepPurple[50],
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditBookScreen(authHeader: widget.authHeader),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _loadBooks();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[100], 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22), 
                ),
                child: const Text(
                  "Add new Book",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),

          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 1.10,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: pageBooks.length,
                          itemBuilder: (context, index) {
                            final book = pageBooks[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                    child: book.photoUrl != null && book.photoUrl!.isNotEmpty
                                        ? Image.network(
                                            _getImageUrl(book.photoUrl!)!, 
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.image, size: 20),
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image, size: 20),
                                          ),
                                  ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(book.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        Text(book.authorName,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        for (int i = 1; i <= 5; i++)
                                          Icon(
                                            i <= (book.averageRating ?? 0).round()
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                        const SizedBox(width: 6),
                                        Text(
                                          (book.averageRating ?? 0).toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            FontAwesomeIcons.penToSquare,
                                            size: 18),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddEditBookScreen(authHeader: widget.authHeader, bookId: book.id),
                                            ),
                                          ).then((value) {
                                            if (value == true) {
                                              _loadBooks();
                                            }
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Confirm Delete'),
                                              content: const Text('Are you sure you want to delete this book?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await _bookProvider.deleteBook(widget.authHeader, book.id);
                                            _loadBooks(); 
                                          }
                                        },
                                      ),

                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: _currentPage > 1
                                  ? () => setState(() => _currentPage--)
                                  : null,
                            ),
                            Text('$_currentPage / $totalPages'),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: _currentPage < totalPages
                                  ? () => setState(() => _currentPage++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
        ),
    );
  }
}
