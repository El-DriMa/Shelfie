import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import '../providers/review_provider.dart';
import '../providers/user_provider.dart';
import '../providers/book_provider.dart';

class ReviewsScreen extends StatefulWidget {
  final String authHeader;
  const ReviewsScreen({required this.authHeader, Key? key}) : super(key: key);

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewProvider _reviewProvider = ReviewProvider();
  final UserProvider _userProvider = UserProvider();
  final BookProvider _bookProvider = BookProvider();

  List<Review> _reviews = [];
  List<String> _usernames = [];
  List<String> _bookTitles = [];

  String? _selectedUsername;
  String? _selectedBook;

  bool _isLoading = true;

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadReviews();
  }

  Future<void> _loadFilters() async {
    var users = await _userProvider.getAll(widget.authHeader);
    var books = await _bookProvider.getAll(widget.authHeader);

    setState(() {
      _usernames = users.map((u) => u.username as String).toList();
      _bookTitles = books.map((b) => b.title as String).toList();
    });
  }

  Future<void> _loadReviews({String? username, String? bookName}) async {
    setState(() => _isLoading = true);
    try {
      var reviews = await _reviewProvider.getAll(
        widget.authHeader,
        username: username,
        bookName: bookName,
      );
      setState(() {
        _reviews = reviews;
        _currentPage = 1;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReview(int id) async {
    try {
      await _reviewProvider.delete(widget.authHeader, id);
      _loadReviews(username: _selectedUsername, bookName: _selectedBook);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete review")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_reviews.length / _itemsPerPage).ceil().clamp(1, 999);
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage < _reviews.length)
        ? _currentPage * _itemsPerPage
        : _reviews.length;
    final pageReviews = _reviews.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Reviews"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Username filter button
                DropdownButtonHideUnderline(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButton<String>(
                        value: _selectedUsername,
                        hint: const Text(
                          "Filter by username",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        items: _usernames
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedUsername = val);
                          _loadReviews(username: val, bookName: _selectedBook);
                        },
                        dropdownColor: Colors.deepPurple[50],
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Book filter button
                DropdownButtonHideUnderline(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButton<String>(
                        value: _selectedBook,
                        hint: const Text(
                          "Filter by book",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        items: _bookTitles
                            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedBook = val);
                          _loadReviews(username: _selectedUsername, bookName: val);
                        },
                        dropdownColor: Colors.deepPurple[50],
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Clear individual filters
                if (_selectedUsername != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.deepPurple),
                    tooltip: "Clear username filter",
                    onPressed: () {
                      setState(() => _selectedUsername = null);
                      _loadReviews(username: null, bookName: _selectedBook);
                    },
                  ),
                if (_selectedBook != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.deepPurple),
                    tooltip: "Clear book filter",
                    onPressed: () {
                      setState(() => _selectedBook = null);
                      _loadReviews(username: _selectedUsername, bookName: null);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
           Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? const Center(child: Text("No reviews available"))
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                        child: DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text("ID")),
                            DataColumn(label: Text("Book")),
                            DataColumn(label: Text("User")),
                            DataColumn(label: Text("Rating")),
                            DataColumn(label: Text("Description")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: pageReviews.map((review) {
                            return DataRow(cells: [
                              DataCell(Text(review.id.toString())),
                              DataCell(Text(review.bookTitle)),
                              DataCell(Text(review.username ?? "")),
                              DataCell(
                                Row(
                                    children: [
                                        Text(
                                        review.rating.toString(),
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                    const SizedBox(width: 6),
                                    for (int i = 1; i <= 5; i++)
                                        Icon(
                                        i <= review.rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 16,
                                        ),
                                    const SizedBox(width: 6),
                                    ]
                                ),
                                ),
                              DataCell(Text(review.description)),
                              DataCell(
                                IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                        title: const Text("Confirm deletion"),
                                        content: const Text("Are you sure you want to delete this review?"),
                                        actions: [
                                            TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                            ),
                                        ],
                                        ),
                                    );
                                    if (confirm == true) {
                                        _deleteReview(review.id);
                                    }
                                    },
                                ),
                                ),

                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                ),
                Text('$_currentPage / $totalPages'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
