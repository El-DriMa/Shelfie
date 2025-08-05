import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shelfie/screens/add_edit_challenge_screen.dart';

import '../config.dart';
import '../models/readingChallenge.dart';
import '../utils/api_helpers.dart';



Future<List<ReadingChallenge>> fetchChallenges(String authHeader) async {

  final response = await http.get(
    Uri.parse('$baseUrl/ReadingChallenge/user'),
    headers: {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);
      final List items = data['items'];

      if (items.isEmpty) {
        print('Post list is empty.');
      } else {
        print('Loaded ${items.length} challenges.');
      }

      return items.map((json) => ReadingChallenge.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error processing data');
    }
  } else {
    throw Exception('Failed to load ReadingChallenge');
  }
}

Future<ReadingChallenge> addChallenge(String authHeader, int userId, String challengeName, String description, int goalType, int goalAmount,
    DateTime startDate, DateTime endDate, int progress, bool isCompleted) async {

  final uri = Uri.parse('$baseUrl/ReadingChallenge');

  final response = await http.post(
    uri,
    headers:  {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
    body: jsonEncode({
      'userId': userId,
      'challengeName': challengeName,
      'description': description,
      'goalType': goalType,
      'goalAmount': goalAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'progress': progress,
      'isCompleted': isCompleted,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    try {
      final data = jsonDecode(response.body);
      return ReadingChallenge.fromJson(data);
    } catch (e) {
      print('JSON parsing error: $e');
      throw Exception('Failed to parse Reading Challenge response');
    }
  } else {
    print('Add new challenge failed: ${response.body}');
    throw Exception('Failed to add new challenge');
  }
}

Future<ReadingChallenge?> deleteChallenge(String authHeader, int id) async {
  final uri = Uri.parse('$baseUrl/ReadingChallenge/$id');

  final response = await http.delete(
    uri,
    headers: {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
  );


  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return ReadingChallenge.fromJson(json);
  } else if (response.statusCode == 204) {
    return null;
  } else {
    throw Exception('Failed to delete book from shelf: ${response.statusCode}');
  }
}

class ReadingChallengeScreen extends StatefulWidget {
  final String authHeader;

  ReadingChallengeScreen({
    required this.authHeader,
  });

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

  String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Future<void> refreshChallenges() async {
    setState(() {
      challengesFuture = fetchChallenges(widget.authHeader);
    });
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

            return Scaffold(
              appBar: AppBar(
                title: Text('Reading Challenges'),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              backgroundColor: Colors.deepPurple[50],
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16, right: 16, left: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.add, color: Colors.deepPurple),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () async {
                            final user = await fetchCurrentUser(
                                widget.authHeader);

                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                AddEditChallengeScreen(
                                      authHeader: widget.authHeader,
                                      userId: user.id,
                                    )
                              ),
                            );

                            if (result == true) {
                              setState(() {
                                challengesFuture =
                                    fetchChallenges(widget.authHeader);
                              });
                            }
                          },
                          child: const Text(
                            'Add New Challenge',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: challenges.isEmpty
                        ? Center(
                      child: Text(
                        'No challenges available',
                        style: TextStyle(
                            fontSize: 18, color: Colors.deepPurple[300]),
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
                                      fontSize: 16,
                                      color: Colors.deepPurple[400]),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Goal: ${c.goalAmount} ${c.goalType
                                          .toLowerCase()}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.deepPurple[700]),
                                    ),
                                    Text(
                                      '${formatDate(
                                          c.startDate)} - ${formatDate(
                                          c.endDate)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.deepPurple[300]),
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
                                  '${c.progress} / ${c.goalAmount} ${c.goalType
                                      .toLowerCase()}',
                                  style: TextStyle(
                                      color: Colors.deepPurple[700]),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    c.isCompleted
                                        ? Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green, size: 20),
                                        SizedBox(width: 6),
                                        Text('Completed',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight:
                                                FontWeight.bold)),
                                      ],
                                    )
                                        : Row(
                                      children: [
                                        Icon(Icons.pending,
                                            color: Colors.orange,
                                            size: 20),
                                        SizedBox(width: 6),
                                        Text('In Progress',
                                            style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight:
                                                FontWeight.bold)),
                                      ],
                                    ),
                                    Spacer(),
                                    TextButton(
                                      onPressed: () async {
                                        final user = await fetchCurrentUser(
                                            widget.authHeader);

                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  AddEditChallengeScreen(
                                                    authHeader: widget.authHeader,
                                                    userId: user.id,
                                                    challengeId: c.id,
                                                  )
                                          ),
                                        );

                                        if (result == true) {
                                          setState(() {
                                            challengesFuture =
                                                fetchChallenges(widget.authHeader);
                                          });
                                        }
                                      },
                                      child: Text('Edit'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirm Delete'),
                                              content: Text('Are you sure you want to delete this reading challenge?'),
                                              actions: [
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(false);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Delete'),
                                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(true);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmed == true) {
                                          await deleteChallenge(widget.authHeader, c.id);
                                          await refreshChallenges();

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Challenge deleted successfully'),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
