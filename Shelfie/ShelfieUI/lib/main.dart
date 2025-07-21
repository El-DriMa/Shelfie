import 'package:flutter/material.dart';
import 'package:shelfie/screens/read_shelf_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shelfie',
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(authHeader: ''),
      },
    );
  }
}
