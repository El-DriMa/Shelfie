import 'package:flutter/material.dart';
import 'package:shelfie/screens/explore_page_screen.dart';
import 'package:shelfie/screens/read_shelf_screen.dart';
import 'package:shelfie/screens/reading_challenges_screen.dart';
import 'package:shelfie/screens/statistics_screen.dart';
import 'package:shelfie/screens/want_to_read_shelf_screen.dart';

import '../models/shelf.dart';

import '../providers/book_provider.dart';
import '../providers/shelf_provider.dart';
import 'currently_reading_shelf_screen.dart';

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


class MyBooksScreen extends StatefulWidget {
  final String authHeader;


  MyBooksScreen({required this.authHeader});


  @override
  _MyBooksScreenState createState() => _MyBooksScreenState();
}


class _MyBooksScreenState extends State<MyBooksScreen>{

  late Future<List<Shelf>> shelvesFuture;
  final _shelfProvider = ShelfProvider();
  final _bookProvider = BookProvider();


  @override
  void initState() {
    super.initState();
    shelvesFuture = _shelfProvider.getAll(widget.authHeader);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Books'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 24.0, bottom: 12.0),
            child: Center(
              child: Text(
                "SHELVES",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurple[400],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(
              color: Colors.black,
              thickness: 2,
            ),
          ),
          Flexible(
            child: FutureBuilder<List<Shelf>>(
              future: shelvesFuture,
              builder: (context, snapshot) {
                print("FutureBuilder state: ${snapshot.connectionState}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading shelves'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No shelves found'));
                }
                final shelves = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  itemCount: shelves.length,
                  itemBuilder: (context, index) {
                    final shelf = shelves[index];
                    Widget imageWidget;
                    switch (shelf.name) {
                      case 'Read':
                        imageWidget = Container(
                          color: Colors.white54,
                          height: 100,
                          width: 80,
                          child: Icon(Icons.library_books, size: 30),
                        );
                        break;
                      case 'WantToRead':
                        imageWidget = Container(
                          color: Colors.white54,
                          height: 100,
                          width: 80,
                          child: Icon(Icons.bookmarks, size: 30),
                        );
                        break;
                      case 'CurrentlyReading':
                        imageWidget = Container(
                          color: Colors.white54,
                          height: 100,
                          width: 80,
                          child: Icon(Icons.menu_book, size: 30),
                        );
                        break;
                      default:
                        imageWidget = Container(
                          color: Colors.white54,
                          height: 100,
                          width: 80,
                          child: Icon(Icons.menu_book_rounded, size: 30),
                        );
                    }

                    return GestureDetector(
                      onTap: () async {
                        Widget screen;
                        switch (shelf.name) {
                          case 'Read':
                            screen = ReadShelfScreen(authHeader: widget.authHeader, shelfId: shelf.id);
                            break;
                          case 'WantToRead':
                            screen = WantToReadShelfScreen(authHeader: widget.authHeader, shelfId: shelf.id);
                            break;
                          case 'CurrentlyReading':
                            screen = CurrentlyReadingShelfScreen(authHeader: widget.authHeader, shelfId: shelf.id);
                            break;
                          default:
                            screen = ExplorePageScreen(authHeader: widget.authHeader);
                        }

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => screen),
                        );

                        if (result == true) {
                          setState(() {
                            shelvesFuture = _shelfProvider.getAll(widget.authHeader);
                          });
                        }
                      },
                      child: Card(
                        color: Colors.deepPurple[200],
                        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              imageWidget,
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      prettifyShelfName(shelf.name),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${shelf.booksCount} books',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white54,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Challenges'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReadingChallengeScreen(authHeader:widget.authHeader)),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.bar_chart),
                    label: Text('Statistics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => StatisticsScreen(authHeader:widget.authHeader)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}