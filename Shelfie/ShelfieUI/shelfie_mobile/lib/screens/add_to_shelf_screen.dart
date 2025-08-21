import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/shelfBooks.dart';
import '../models/shelf.dart';
import '../providers/book_provider.dart';
import '../providers/shelf_books_provider.dart';
import '../providers/shelf_provider.dart';

String prettifyShelfName(String rawName) {
  switch (rawName) {
    case 'CurrentlyReading':
      return 'Currently Reading';
    case 'WantToRead':
      return 'Want to Read';
    case 'Read':
      return 'Read';
    default:
      return rawName.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
        return '${match.group(1)} ${match.group(2)}';
      });
  }
}


class AddToShelfScreen extends StatefulWidget {
  final String authHeader;
  final int bookId;
  AddToShelfScreen({required this.authHeader,required this.bookId});

  @override
  State<AddToShelfScreen> createState() => _AddToShelfScreenState();
}

class _AddToShelfScreenState extends State<AddToShelfScreen> {
  int? _selectedShelfId;
  final _provider = ShelfBooksProvider();
  final _shelfProvider = ShelfProvider();
  final _bookProvider = BookProvider();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add to Shelf'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<Book>(
        future: _bookProvider.getById(widget.authHeader, widget.bookId),
        builder: (context, bookSnapshot) {
          if (bookSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (bookSnapshot.hasError) {
            return Center(child: Text('Error: ${bookSnapshot.error}'));
          } else if (!bookSnapshot.hasData) {
            return const Center(child: Text('No book data found'));
          }

          final book = bookSnapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        book.photoUrl != null
                            ? Image.network(
                          book.photoUrl!,
                          height: 180,
                          width: 120,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          height: 180,
                          width: 120,
                          color: const Color(0xFFE0E0E0),
                          child: const Icon(
                              Icons.book, size: 60, color: Color(0xFF9E9E9E)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title ?? 'Unknown Book',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                book.authorName ?? 'Unknown Author',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'ADD TO SHELF',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                FutureBuilder<List<Shelf>>(
                  future: _shelfProvider.getAll(widget.authHeader),
                  builder: (context, shelfSnapshot) {
                    if (shelfSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (shelfSnapshot.hasError) {
                      return Text(
                          'Failed to load shelves: ${shelfSnapshot.error}');
                    } else
                    if (!shelfSnapshot.hasData || shelfSnapshot.data!.isEmpty) {
                      return const Text('No shelves available.');
                    }

                    final shelves = shelfSnapshot.data!;
                    if (_selectedShelfId == null && shelves.isNotEmpty) {
                      _selectedShelfId = shelves.first.id;
                    }


                    return Column(
                      children: shelves.map((shelf) {
                        return RadioListTile<int>(
                          title: Text(prettifyShelfName(shelf.name)),
                          value: shelf.id,
                          groupValue: _selectedShelfId,
                          onChanged: (value) {
                            setState(() {
                              _selectedShelfId = value;
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    try {
                      final result = await _provider.addToShelf(widget.authHeader, book.id, _selectedShelfId!);
                      final shelfName = result.shelfName?? 'Unknown Shelf';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to shelf: $shelfName')),
                      );

                      await Future.delayed(const Duration(seconds: 2));
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This book is already in the selected shelf.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },

                  child: const Text('Add to Selected Shelf'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}