import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class UsersScreen extends StatefulWidget {
  final String authHeader;

  UsersScreen({required this.authHeader});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: const Center(
        child: Text(
          'Users Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
