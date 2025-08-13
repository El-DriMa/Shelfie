import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class BooksScreen extends StatefulWidget {
  final String authHeader;

  BooksScreen({required this.authHeader});

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: const Center(
        child: Text(
          'Books Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
