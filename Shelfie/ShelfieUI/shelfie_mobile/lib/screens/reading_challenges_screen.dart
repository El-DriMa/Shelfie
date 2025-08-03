import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/readingChallenge.dart';



Future<List<ReadingChallenge>> fetchChallenges(String authHeader) async {

  final response = await http.get(
    Uri.parse('$baseUrl/ReadingChallenge/user'),
    headers: {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
  );
  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);
      final List items = data['items'];

      if (items.isEmpty) {
        print('Post list is empty.');
      } else {
        print('Loaded ${items.length} posts.');
      }

      return items.map((json) => ReadingChallenge.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error processing data');
    }
  } else {
    throw Exception('Failed to load ReadingChallenge');
  }
}

class ReadingChallengeScreen extends StatefulWidget {

  final String authHeader;


  ReadingChallengeScreen({required this.authHeader});

  @override
  _ReadingChallengeScreenState createState() => _ReadingChallengeScreenState();
}

class _ReadingChallengeScreenState extends State<ReadingChallengeScreen> {
  late Future<List<ReadingChallenge>> challengesFuture;


  @override
  void initState() {
    super.initState();
    challengesFuture = fetchChallenges(widget.authHeader);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReadingChallenge>>(
      future: challengesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Reading Challenges')),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Reading Challenges')),
            body: Center(child: Text('Error loading challenges')),
          );
        } else {
          final challenges = snapshot.data ?? [];
          return ReadingChallengeScreenUI(challenges: challenges);
        }
      },
    );
  }
}

class ReadingChallengeScreenUI extends StatelessWidget {
  final List<ReadingChallenge> challenges;

  ReadingChallengeScreenUI({required this.challenges});

  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Challenges'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: challenges.isEmpty
          ? Center(
        child: Text(
          'No challenges available',
          style: TextStyle(fontSize: 18, color: Colors.deepPurple[300]),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final c = challenges[index];
          double progressPercent =
          c.goalAmount > 0 ? c.progress / c.goalAmount : 0;

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.challengeName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[600]),
                  ),
                  SizedBox(height: 6),
                  Text(
                    c.description,
                    style: TextStyle(
                        fontSize: 16, color: Colors.deepPurple[400]),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Goal: ${c.goalAmount} ${c.goalType.toLowerCase()}',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple[700]),
                      ),
                      Text(
                        '${formatDate(c.startDate)} - ${formatDate(c.endDate)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.deepPurple[300]),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progressPercent.clamp(0, 1),
                    color: Colors.deepPurple,
                    backgroundColor: Colors.deepPurple[100],
                    minHeight: 8,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${c.progress} / ${c.goalAmount} ${c.goalType.toLowerCase()}',
                    style: TextStyle(color: Colors.deepPurple[700]),
                  ),
                  SizedBox(height: 8),
                  if (c.isCompleted)
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        SizedBox(width: 6),
                        Text('Completed',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.pending,
                            color: Colors.orange, size: 20),
                        SizedBox(width: 6),
                        Text('In Progress',
                            style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
