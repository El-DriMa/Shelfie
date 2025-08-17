import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/shelfBooks.dart';
import '../providers/shelf_books_provider.dart';
import '../providers/user_provider.dart';

class ShelfBooksScreen extends StatefulWidget {
  final String authHeader;
  const ShelfBooksScreen({required this.authHeader, Key? key}) : super(key: key);

  @override
  _ShelfBooksScreenState createState() => _ShelfBooksScreenState();
}

class _ShelfBooksScreenState extends State<ShelfBooksScreen> {
  final ShelfBooksProvider _shelfBooksProvider = ShelfBooksProvider();
  final UserProvider _userProvider = UserProvider();

  List<ShelfBooks> _books = [];
  List<String> _usernames = [];
  final List<String> _shelfNames = ["Read", "CurrentlyReading", "WantToRead"];

  String? _selectedUsername;
  String? _selectedShelfName;

  bool _isLoading = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadBooks();
  }

  Future<void> _loadFilters() async {
    var users = await _userProvider.getAll(widget.authHeader);
    setState(() {
      _usernames = users.map((u) => u.username as String).toList();
    });
  }

  Future<void> _loadBooks({String? username, String? shelfName}) async {
    setState(() => _isLoading = true);
    try {
      var books = await _shelfBooksProvider.getAll(
        widget.authHeader,
        username: username,
        shelfName: shelfName,
      );
      setState(() {
        _books = books;
        _currentPage = 1;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_books.length / _itemsPerPage).ceil().clamp(1, 999);
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage < _books.length)
        ? _currentPage * _itemsPerPage
        : _books.length;
    final pageBooks = _books.sublist(startIndex, endIndex).cast<ShelfBooks>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Shelf Books"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButtonHideUnderline(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
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
                          _loadBooks(username: val, shelfName: _selectedShelfName);
                        },
                        dropdownColor: Colors.deepPurple[50],
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButton<String>(
                        value: _selectedShelfName,
                        hint: const Text(
                          "Filter by shelf",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        items: _shelfNames
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedShelfName = val);
                          _loadBooks(username: _selectedUsername, shelfName: val);
                        },
                        dropdownColor: Colors.deepPurple[50],
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_selectedUsername != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.deepPurple),
                    onPressed: () {
                      setState(() => _selectedUsername = null);
                      _loadBooks(username: null, shelfName: _selectedShelfName);
                    },
                  ),
                if (_selectedShelfName != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.deepPurple),
                    onPressed: () {
                      setState(() => _selectedShelfName = null);
                      _loadBooks(username: _selectedUsername, shelfName: null);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _books.isEmpty
                      ? const Center(child: Text("No shelf books available"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                            child: DataTable(
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text("ID")),
                                DataColumn(label: Text("Shelf")),
                                DataColumn(label: Text("Book Title")),
                                DataColumn(label: Text("Author")),
                                DataColumn(label: Text("Pages Read")),
                                DataColumn(label: Text("Total Pages")),
                                DataColumn(label: Text("Username")),
                              ],
                              rows: pageBooks.map((b) {
                                return DataRow(cells: [
                                  DataCell(Text(b.id.toString())),
                                  DataCell(Text(b.shelfName ?? "")),
                                  DataCell(Text(b.bookTitle ?? "")),
                                  DataCell(Text(b.authorName ?? "")),
                                  DataCell(Text(b.pagesRead?.toString() ?? "")),
                                  DataCell(Text(b.totalPages?.toString() ?? "")),
                                  DataCell(Text(b.username ?? "")),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
            ),
            // Pagination
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
