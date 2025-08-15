import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/genre.dart';
import '../models/author.dart';
import '../models/publisher.dart';
import '../providers/genre_provider.dart';
import '../providers/author_provider.dart';
import '../providers/publisher_provider.dart';
import '../providers/book_provider.dart';
import '../config.dart';

class AddEditBookScreen extends StatefulWidget {
  final String authHeader;
  final int? bookId;

  AddEditBookScreen({required this.authHeader, this.bookId});

  @override
  _AddEditBookScreenState createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookProvider _bookProvider = BookProvider();
  final GenreProvider _genreProvider = GenreProvider();
  final AuthorProvider _authorProvider = AuthorProvider();
  final PublisherProvider _publisherProvider = PublisherProvider();

  List<Genre> _genres = [];
  List<Author> _authors = [];
  List<Publisher> _publishers = [];

  int? _selectedGenreId;
  int? _selectedAuthorId;
  int? _selectedPublisherId;

  bool _isLoading = true;
  bool _isSaving = false;
  Book? _book;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _coverController = TextEditingController();

    final List<String> _languages = [
    "English",
    "Bosnian",
    "Spanish",
    "German",
    "French",
    "Italian",
    "Turkish",
    "Arabic",
    "Russian",
    "Chinese"
    ];

    String? _selectedLanguage;


  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    await _loadDropdowns();
    if (widget.bookId != null) {
      await _loadBook(widget.bookId!);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadDropdowns() async {
    try {
      _genres = (await _genreProvider.fetchGenres(widget.authHeader)).cast<Genre>();
      _authors = (await _authorProvider.getAll(widget.authHeader)).cast<Author>();
      _publishers = (await _publisherProvider.getAll(widget.authHeader)).cast<Publisher>();
      setState(() {});
    } catch (_) {}
  }

  Future<void> _loadBook(int id) async {
    try {
      _book = await _bookProvider.getById(widget.authHeader, id);
      setState(() {
        _titleController.text = _book!.title;
        _pagesController.text = _book!.totalPages.toString();
        _yearController.text = _book!.yearPublished.toString();
        _descController.text = _book!.shortDescription;
        _languageController.text = _book!.language;
        _coverController.text = _book!.coverImage ?? '';

        _selectedGenreId = _book!.genreId;
        _selectedAuthorId = _book!.authorId;
        _selectedPublisherId = _book!.publisherId;
      });
    } catch (_) {}
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final bookData = <String, dynamic>{
      "title": _titleController.text,
      "totalPages": int.tryParse(_pagesController.text) ?? 0,
      "yearPublished": int.tryParse(_yearController.text) ?? 0,
      "shortDescription": _descController.text,
      "language": _selectedLanguage,
      "genreId": _selectedGenreId,
      "authorId": _selectedAuthorId,
      "publisherId": _selectedPublisherId,
      "coverImage": _coverController.text.isNotEmpty ? _coverController.text.codeUnits : null,
    };

    if (_book != null && _book!.id > 0) {
      await _bookProvider.updateBook(widget.authHeader, _book!.id, bookData);
    } else {
      await _bookProvider.createBook(widget.authHeader, bookData);
    }

    setState(() => _isSaving = false);
    Navigator.pop(context, true);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookId != null ? "Edit Book" : "Add New Book"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width > 600 ? 600 : double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                    border: Border.all(color: Colors.deepPurple.shade100),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length > 200) return 'Maximum 200 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedAuthorId,
                          decoration: const InputDecoration(labelText: 'Author', border: OutlineInputBorder()),
                          items: _authors.map((a) => DropdownMenuItem(value: a.id, child: Text(a.fullName))).toList(),
                          onChanged: (val) => setState(() => _selectedAuthorId = val),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedGenreId,
                          decoration: const InputDecoration(labelText: 'Genre', border: OutlineInputBorder()),
                          items: _genres.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                          onChanged: (val) => setState(() => _selectedGenreId = val),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedPublisherId,
                          decoration: const InputDecoration(labelText: 'Publisher', border: OutlineInputBorder()),
                          items: _publishers.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                          onChanged: (val) => setState(() => _selectedPublisherId = val),
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pagesController,
                          decoration: const InputDecoration(labelText: 'Total Pages', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final n = int.tryParse(v);
                              if (n == null || n < 1) return 'Must be positive number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(labelText: 'Year Published', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.isNotEmpty) {
                              final n = int.tryParse(v);
                              if (n == null || n < 1 || n > 2025) return 'Invalid year';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(labelText: 'Short Description', border: OutlineInputBorder()),
                          maxLines: 3,
                          validator: (v) => v != null && v.length > 1000 ? 'Maximum 1000 characters' : null,
                        ),
                        const SizedBox(height: 16),
                       DropdownButtonFormField<String>(
                        value: _selectedLanguage ?? _book?.language,
                        decoration: const InputDecoration(labelText: 'Language', border: OutlineInputBorder()),
                        items: _languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                        onChanged: (val) => setState(() => _selectedLanguage = val),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _coverController,
                          decoration: const InputDecoration(labelText: 'Cover Image URL', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveBook,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(_isSaving ? "Saving..." : (widget.bookId != null ? "Update Book" : "Add Book"), style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
