import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../config.dart' as BaseProvider;
import '../models/book.dart';
import '../providers/book_provider.dart';

String? _getImageUrl(String photoUrl) {
  if (photoUrl.isEmpty) return null;
  if (photoUrl.startsWith('http')) return photoUrl;

  String base = BaseProvider.baseUrl ?? '';
  base = base.replaceAll(RegExp(r'/api/?$'), '');

  return '$base/$photoUrl';
}

class BookDetailsScreen extends StatelessWidget {
  final String authHeader;
  final int bookId;
  final _provider = BookProvider();

  BookDetailsScreen({required this.authHeader, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<Book>(
        future: _provider.getById(authHeader, bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final book = snapshot.data!;
          final imageUrl = _getImageUrl(book.photoUrl ?? '');

          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.white,
                child: Center(
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 220,
                      width: 140,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            height: 220,
                            width: 140,
                            color: const Color(0xFFE0E0E0),
                            child: const Icon(Icons.book,
                                size: 80, color: Color(0xFF9E9E9E)),
                          ),
                    ),
                  )
                      : Container(
                    height: 220,
                    width: 140,
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(Icons.book,
                        size: 80, color: Color(0xFF9E9E9E)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(book.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 4),
                        Text(book.authorName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        const SizedBox(height: 24),
                        _infoRow(Icons.category, 'Genre', book.genreName),
                        _infoRow(Icons.language, 'Language', book.language),
                        _infoRow(Icons.menu_book, 'Pages', '${book.totalPages}'),
                        _infoRow(Icons.calendar_today, 'Year', '${book.yearPublished}'),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text('Description',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(book.shortDescription,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.justify),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 26),
          const SizedBox(width: 12),
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
