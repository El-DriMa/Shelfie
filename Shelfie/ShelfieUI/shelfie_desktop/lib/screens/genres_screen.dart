import 'package:flutter/material.dart';
import '../models/genre.dart';
import '../providers/genre_provider.dart';

class GenresScreen extends StatefulWidget {
  final String authHeader;
  const GenresScreen({required this.authHeader, Key? key}) : super(key: key);

  @override
  _GenresScreenState createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  final GenreProvider _genreProvider = GenreProvider();
  List<Genre> _genres = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortOrder = 'A-Z';

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  final TextEditingController _nameController = TextEditingController();
  Map<int, TextEditingController> _editingControllers = {};
  Set<int> _editingIds = {};

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

    void _sortGenres() {
    if (_sortOrder == 'A-Z') {
        _genres.sort((a, b) => a.name.compareTo(b.name));
    } else {
        _genres.sort((a, b) => b.name.compareTo(a.name));
    }
    }


  Future<void> _loadGenres() async {
    setState(() => _isLoading = true);
    try {
      var genres = await _genreProvider.fetchGenres(widget.authHeader);
      setState(() {
        _genres = genres;
         _sortGenres(); 
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchGenres(String query) async {
    setState(() => _isLoading = true);
    try {
      var genres = await _genreProvider.searchGenres(widget.authHeader, query);
      setState(() {
        _genres = genres;
        _isLoading = false;
        _currentPage = 1;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

 Future<void> _addGenre() async {
  if (_nameController.text.isEmpty) return;
  try {
    await _genreProvider.createGenre(widget.authHeader, {'name': _nameController.text});
    _nameController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Genre added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    _loadGenres();
  } catch (e) {
    String errorMsg = e.toString();
    if (errorMsg.startsWith("Exception: ")) {
      errorMsg = errorMsg.replaceFirst("Exception: ", "");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Future<void> _updateGenre(int id) async {
  var controller = _editingControllers[id];
  if (controller == null || controller.text.isEmpty) return;

  try {
    await _genreProvider.updateGenre(widget.authHeader, id, {'name': controller.text});
    _editingIds.remove(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Genre updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    _loadGenres();
  } catch (e) {
    String errorMsg = e.toString();
    if (errorMsg.startsWith("Exception: ")) {
      errorMsg = errorMsg.replaceFirst("Exception: ", "");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.red,
      ),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    final totalPages = (_genres.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage < _genres.length)
        ? _currentPage * _itemsPerPage
        : _genres.length;
    final pageGenres = _genres.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Genres'),
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
                      hintText: 'Search genres',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _searchGenres(value);
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
                                _sortGenres(); 
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
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width / 2),
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Name')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: pageGenres.map((genre) {
                                  _editingControllers.putIfAbsent(
                                      genre.id, () => TextEditingController(text: genre.name));
                                  final isEditing = _editingIds.contains(genre.id);
                                  return DataRow(cells: [
                                    DataCell(Text(genre.id.toString())),
                                    DataCell(
                                      isEditing
                                          ? SizedBox(
                                              width: 150,
                                              child: TextField(
                                                controller: _editingControllers[genre.id],
                                              ),
                                            )
                                          : Text(genre.name),
                                    ),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            if (isEditing) {
                                              _updateGenre(genre.id);
                                            } else {
                                              setState(() => _editingIds.add(genre.id));
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('Confirm Delete'),
                                                content: const Text('Are you sure you want to delete this genre?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('Cancel')),
                                                  TextButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text('Delete')),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await _genreProvider.deleteGenre(widget.authHeader, genre.id);
                                              _loadGenres();
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
                  const SizedBox(width: 20),
                  Container(
                    width: 250,
                    height: 250,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Add New Genre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Genre Name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _addGenre,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                          child: const Text('Add Genre', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null),
                  Text('$_currentPage / $totalPages'),
                  IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
