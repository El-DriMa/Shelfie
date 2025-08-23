import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/statistics_provider.dart';
import '../models/statistics.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class StatisticsScreen extends StatefulWidget {
  final String authHeader;

  const StatisticsScreen({required this.authHeader, Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  final _provider = StatisticsProvider();
  Statistics? _stats;
  bool _isLoading = true;
  bool _showGenres = false;
  bool _showTopUsers = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _provider.getAppStatistics(widget.authHeader);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load statistics: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _generatePdfReport() async {
  if (_stats == null) return;

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('App Statistics Report',
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),

            pw.Text('Total Users: ${_stats!.totalUsers}'),
            pw.Text('Total Books: ${_stats!.totalBooks}'),
            pw.Text('Total Authors: ${_stats!.totalAuthors}'),
            pw.Text('Total Reviews: ${_stats!.totalReviews}'),
            pw.Text('Average Rating: ${_stats!.averageRating.toStringAsFixed(1)}'),

            pw.SizedBox(height: 20),

            pw.Text('Most Read Genres:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: List.generate(_stats!.mostReadGenres.length, (i) {
                return pw.Text(
                    '- ${_stats!.mostReadGenres[i]} (${_stats!.mostReadGenresCounts[i]})');
              }),
            ),

            pw.SizedBox(height: 20),

            pw.Text('Top Users:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: List.generate(_stats!.topUsers.length, (i) {
                return pw.Text(
                    '- ${_stats!.topUsers[i]} (${_stats!.topUsersCounts[i]})');
              }),
            ),
          ],
        );
      },
    ),
  );

  String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Report As',
        fileName: 'report.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (outputFile != null) {
        if (!outputFile.toLowerCase().endsWith('.pdf')) {
          outputFile = '$outputFile.pdf';
        }

        final file = File(outputFile);
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved at $outputFile')),
        );
}

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('App Statistics', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        actions: [
        IconButton(
          icon: Icon(Icons.picture_as_pdf),
          iconSize: 32, 
          onPressed: _generatePdfReport, 
        ),
      ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text("No statistics available"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    children: [
                      _buildStatCard("Users", _stats!.totalUsers.toString(), FontAwesomeIcons.users, Colors.deepPurple),
                      _buildStatCard("Books", _stats!.totalBooks.toString(), FontAwesomeIcons.bookOpen, Colors.orange),
                      _buildStatCard("Authors", _stats!.totalAuthors.toString(), FontAwesomeIcons.userTie, Colors.green),
                      _buildStatCard("Reviews", _stats!.totalReviews.toString(), FontAwesomeIcons.commentDots, Colors.blue),
                      _buildStatCard("Avg Rating", _stats!.averageRating.toStringAsFixed(1), FontAwesomeIcons.starHalfAlt, Colors.amber),
                      _buildOverlayCard(
                        "Most Read Genres",
                        _stats!.mostReadGenres,
                        _stats!.mostReadGenresCounts,
                        Colors.purple,
                        () => setState(() => _showGenres = !_showGenres),
                        _showGenres,
                      ),
                      _buildOverlayCard(
                        "Top Users",
                        _stats!.topUsers,
                        _stats!.topUsersCounts,
                        Colors.teal,
                        () => setState(() => _showTopUsers = !_showTopUsers),
                        _showTopUsers,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 6,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.7), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 28,
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildOverlayCard(String title, List<String> items, List<int> counts, Color color, VoidCallback onTap, bool isOpen) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    child: Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isOpen
              ? Column(
                  children: List.generate(items.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: Text(items[index],
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
                          CircleAvatar(
                            backgroundColor: color,
                            radius: 5,
                            child: Text(counts[index].toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  }),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: color,
                      radius: 24,
                      child: Icon(FontAwesomeIcons.list, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                  ],
                ),
        ),
      ),
    ),
  );
}


}
