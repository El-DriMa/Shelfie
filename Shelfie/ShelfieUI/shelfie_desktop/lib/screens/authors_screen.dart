import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';
class AuthorsScreen extends StatefulWidget {
  final String authHeader;

  AuthorsScreen({required this.authHeader});

  @override
  _AuthorsScreenState createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authors'),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: const Center(
        child: Text(
          'Authors Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
