import 'package:flutter/material.dart';
import 'package:shelfie/screens/notifications_screen.dart';
import 'package:shelfie/screens/profile_screen.dart';
import 'community_screen.dart';
import 'explore_page_screen.dart';
import 'my_books_screen.dart';

class MainScreen extends StatefulWidget {
  final String authHeader;

  MainScreen({required this.authHeader});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ExplorePageScreen(authHeader: widget.authHeader),
      MyBooksScreen(authHeader: widget.authHeader),
      CommunityScreen(authHeader: widget.authHeader),
      NotificationsScreen(authHeader: widget.authHeader),
      ProfileScreen(authHeader: widget.authHeader),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        backgroundColor: Colors.deepPurple,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Books'),
          BottomNavigationBarItem(icon: Icon(Icons.comment), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}