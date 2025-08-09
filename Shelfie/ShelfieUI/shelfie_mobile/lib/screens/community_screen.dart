import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shelfie/screens/posts_screen.dart';

import '../models/book.dart';
import 'package:shelfie/config.dart';
import '../models/genre.dart';
import '../providers/genre_provider.dart';
import '../utils/api_helpers.dart';

class CommunityScreen extends StatefulWidget {
  final String authHeader;

  CommunityScreen({required this.authHeader});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>{

  late Future<List<Genre>> genres;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();
  final _genreProvider = GenreProvider();

  void _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      genres = _genreProvider.fetchGenres(widget.authHeader);
    });
  }

  void _onSearchSubmitted(String query) {
    print('Search called with query: $query');
    setState(() {
      if (query.trim().isEmpty) {
        genres = _genreProvider.fetchGenres(widget.authHeader);
      } else {
        genres = _genreProvider.searchGenres(widget.authHeader,query);

        print('Search result for: $query, result: $genres');

      }
    });
  }


  @override
  void initState() {
    super.initState();
    genres=_genreProvider.fetchGenres(widget.authHeader);
  }


  void _showSearchDialog() async {
    String query = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search Genre'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Type anything...'),
            onChanged: (v) => query = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, query),
              child: Text('Search'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        genres = _genreProvider.searchGenres(widget.authHeader,result);
      });
    }
  }


  void navigateToDiscussion(int genreId, String genreName) {
    Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => PostsScreen(
        authHeader: widget.authHeader,
        genreId: genreId,
        genreName: genreName,
        )
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.deepPurple[100],
        title: isSearching
            ? TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Name...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white38),

          ),
          style: TextStyle(color: Colors.white),
            onChanged: (value) {
              _onSearchSubmitted(value);
            },
        )
            : Text(
          'Community',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: isSearching
            ? [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: _stopSearch,
          ),
        ]
            : [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: Text('Search by genre name',  style: TextStyle(fontSize: 12, color: Colors.grey))),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _startSearch,
          ),

        ],
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Padding(
        padding: EdgeInsets.all(20),
        child: FutureBuilder<List<Genre>>(
          future: genres,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load genres'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No genres found'));
            }

            final genres = snapshot.data!;
            return ListView.builder(
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade300,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => navigateToDiscussion(genre.id, genre.name),
                    child: Text(genre.name, style: TextStyle(fontSize: 18)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}