import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';

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
        elevation: 1,
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
          return Column(
            children: [
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: book.photoUrl != null
                      ? Image.network(
                    book.photoUrl!,
                    fit: BoxFit.cover,
                    height: 220,
                    width: 150,
                  )
                      : Container(
                    height: 220,
                    width: 150,
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(Icons.book, size: 80, color: Color(0xFF9E9E9E)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                        //const SizedBox(height: 5),
                        Text(book.authorName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black)),
                        const SizedBox(height: 12),
                        Text('Genre: ${book.genreName}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Language: ${book.language}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Total Pages: ${book.totalPages}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Year Published: ${book.yearPublished}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          'Description: ${book.shortDescription}',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify,
                        ),
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
}


