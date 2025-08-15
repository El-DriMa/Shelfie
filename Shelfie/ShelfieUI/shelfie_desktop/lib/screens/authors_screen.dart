import 'package:flutter/material.dart';
import '../models/author.dart';
import '../providers/author_provider.dart';
import 'package:intl/intl.dart';
import 'add_edit_author_screen.dart';

class AuthorsScreen extends StatefulWidget {
  final String authHeader;
  const AuthorsScreen({required this.authHeader, Key? key}) : super(key: key);

  @override
  _AuthorsScreenState createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  final AuthorProvider _authorProvider = AuthorProvider();
  List<Author> _authors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortOrder = 'A-Z';

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    try {
      var authors = await _authorProvider.getAll(widget.authHeader);
      setState(() {
        _authors = authors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchAuthors(String query) async {
    setState(() => _isLoading = true);
    try {
      var authors =
          await _authorProvider.searchAuthors(widget.authHeader, query);
      setState(() {
        _authors = authors;
        _isLoading = false;
        _currentPage = 1;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

   @override
Widget build(BuildContext context) {
  final totalPages = (_authors.length / _itemsPerPage).ceil();
  final startIndex = (_currentPage - 1) * _itemsPerPage;
  final endIndex = (_currentPage * _itemsPerPage < _authors.length)
      ? _currentPage * _itemsPerPage
      : _authors.length;
  final pageAuthors = _authors.sublist(startIndex, endIndex);

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text('Authors'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    body: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search authors',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _searchAuthors(value);
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
                          if (_sortOrder == 'A-Z') {
                            _authors.sort((a, b) =>
                                a.lastName.compareTo(b.lastName));
                          } else {
                            _authors.sort((a, b) =>
                                b.lastName.compareTo(a.lastName));
                          }
                          _currentPage = 1;
                        });
                      },
                      dropdownColor: Colors.deepPurple[50],
                      style:
                          const TextStyle(color: Colors.black, fontSize: 14),
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
                                              builder: (context) => AddEditAuthorScreen(authHeader: widget.authHeader),
                                            ),
                                          ).then((value) {
                                            if (value == true) {
                                              _loadAuthors();
                                            }
                                          });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 22),
                ),
                child: const Text(
                  "Add new Author",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width),
                      child: DataTable(
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Last Name')),
                          DataColumn(label: Text('First Name')),
                          DataColumn(label: Text('Birth Date')),
                          DataColumn(label: Text('Birth Country')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: pageAuthors.map((author) {
                          return DataRow(cells: [
                            DataCell(Text(author.id.toString())),
                            DataCell(Text(author.lastName)),
                            DataCell(Text(author.firstName)),
                            DataCell(Text(
                              author.birthDate != null
                                  ? DateFormat('dd.MM.yyyy')
                                      .format(author.birthDate!)
                                  : '',
                            )),
                            DataCell(Text(author.birthCountry ?? '')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddEditAuthorScreen(authHeader: widget.authHeader, authorId: author.id),
                                            ),
                                          ).then((value) {
                                            if (value == true) {
                                              _loadAuthors();
                                            }
                                          });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this author?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete')),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await _authorProvider.deleteAuthor(
                                          widget.authHeader, author.id);
                                      _loadAuthors();
                                    }
                                  },
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
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
  );
}
}
