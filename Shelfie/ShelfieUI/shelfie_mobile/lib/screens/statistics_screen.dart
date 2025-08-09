import 'package:flutter/material.dart';
import 'package:shelfie/models/statistics.dart';
import 'package:intl/intl.dart';

import '../providers/statistics_provider.dart';


class StatisticsScreen extends StatefulWidget {
  final String authHeader;
  StatisticsScreen({required this.authHeader});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<List<Statistics>> futureStats;
  final _provider= StatisticsProvider();

  @override
  void initState() {
    super.initState();
    futureStats = _provider.statsForUser(widget.authHeader);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Widget buildSimpleStatCard(String label, String value, {Color? color, IconData? icon}) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color ?? Colors.deepPurple.shade700)),
            SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: color ?? Colors.deepPurple.shade900)),
          ],
        ),
      ),
    );
  }

  Widget buildStatCardWithList(String label, List<String> values, {Color? color, IconData? icon}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color ?? Colors.deepPurple.shade700)),
            SizedBox(height: 8),
            ...values.map((v) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(v,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color ?? Colors.deepPurple.shade900)),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: Text('📚 Reading Statistics'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Statistics>>(
        future: futureStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No statistics available.',
                    style: TextStyle(color: Colors.deepPurple.shade300)));
          }
          final stats = snapshot.data!.first;

          return SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  childAspectRatio: 3 / 2.5,
                  children: [
                    buildSimpleStatCard('Total Read Books', '${stats.totalReadBooks}', color: Colors.indigo, icon: Icons.menu_book),
                    buildSimpleStatCard('Total Books in Shelf', '${stats.totalBooksInShelf}', color: Colors.teal, icon: Icons.library_books),
                    buildSimpleStatCard('Total Pages Read', '${stats.totalPagesRead}', color: Colors.deepOrange, icon: Icons.chrome_reader_mode),
                    buildSimpleStatCard('Most Read Genre', stats.mostReadGenreName, color: Colors.purple, icon: Icons.auto_stories),
                    buildSimpleStatCard('First Book Read Date', formatDate(stats.firstBookReadDate), color: Colors.blue, icon: Icons.calendar_today),
                    buildSimpleStatCard('Last Book Read Date', formatDate(stats.lastBookReadDate), color: Colors.blueGrey, icon: Icons.calendar_view_day),
                    buildSimpleStatCard('Unique Genres Count', '${stats.uniqueGenresCount}', color: Colors.brown, icon: Icons.category),
                    buildSimpleStatCard('Top Author', stats.topAuthor, color: Colors.deepPurple, icon: Icons.person),
                  ],
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Book with Least Pages',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade700)),
                        SizedBox(height: 8),
                        Text('${stats.bookWithLeastPagesTitle} (${stats.bookWithLeastPagesCount} pages)',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade900)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Book with Most Pages',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.redAccent.shade700)),
                        SizedBox(height: 8),
                        Text('${stats.bookWithMostPagesTitle} (${stats.bookWithMostPagesCount} pages)',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent.shade700)),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Unique Genres',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.brown.shade700)),
                        SizedBox(height: 8),
                        ...stats.uniqueGenresNames.map((genre) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            genre,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.brown.shade900),
                          ),
                        )),
                      ],
                    ),
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

