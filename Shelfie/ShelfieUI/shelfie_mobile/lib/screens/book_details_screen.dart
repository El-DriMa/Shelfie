import 'dart:convert';
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Book Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
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
                height: 260,
                color: Colors.white,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 240,
                      width: 160,
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholderImage(),
                    )
                        : _placeholderImage(),
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black12)],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(book.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 6),
                        Text(book.authorName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87)),
                        const SizedBox(height: 24),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _infoCard(Icons.category, 'Genre', book.genreName),
                            _infoCard(Icons.language, 'Language', book.language),
                            _infoCard(Icons.menu_book, 'Pages', '${book.totalPages}'),
                            _infoCard(Icons.calendar_today, 'Year', '${book.yearPublished}'),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(thickness: 1),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.center,
                          child: Text('Description',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text(book.shortDescription,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
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

  Widget _placeholderImage() {
    return Container(
      height: 240,
      width: 160,
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.book, size: 80, color: Colors.deepPurple),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurpleAccent, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              )),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
        ],
      ),
    );
  }

}
