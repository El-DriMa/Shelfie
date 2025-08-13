import 'package:flutter/material.dart';
import 'books_screen.dart';
import 'users_screen.dart';
import 'authors_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final String authHeader;

  const MainScreen({required this.authHeader});

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
      BooksScreen(authHeader: widget.authHeader),
      UsersScreen(authHeader: widget.authHeader),
      AuthorsScreen(authHeader: widget.authHeader),
    ];
  }

  void _logout() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _screens.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.deepPurple,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Shelfie',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Expanded(
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.amber,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    onTap: (index) =>
                        setState(() => _currentIndex = index),
                    tabs: const [
                      Tab(text: 'Books'),
                      Tab(text: 'Users'),
                      Tab(text: 'Authors'),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                        ),
                        ),
                        onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('authToken');
                        Navigator.pushReplacementNamed(context, '/login');
                        },
                    ),
                ),
              ],
            ),
          ),
        ),
        body: _screens[_currentIndex],
      ),
    );
  }
}
