import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/readingChallenge.dart';
import '../providers/reading_challenge_provider.dart';
import '../providers/user_provider.dart';

class ReadingChallengesScreen extends StatefulWidget {
  final String authHeader;
  const ReadingChallengesScreen({required this.authHeader, Key? key})
      : super(key: key);

  @override
  _ReadingChallengesScreenState createState() =>
      _ReadingChallengesScreenState();
}

class _ReadingChallengesScreenState extends State<ReadingChallengesScreen> {
  final ReadingChallengeProvider _challengeProvider = ReadingChallengeProvider();
  final UserProvider _userProvider = UserProvider();

  List<ReadingChallenge> _challenges = [];
  List<String> _usernames = [];
  String? _selectedUsername;
  bool _isLoading = true;

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadChallenges();
  }

  Future<void> _loadUsers() async {
    var users = await _userProvider.getAll(widget.authHeader);
    setState(() {
      _usernames = users.map((u) => u.username as String).toList();
    });
  }

  Future<void> _loadChallenges({String? username}) async {
  try {
    var challenges =
        await _challengeProvider.getAll(widget.authHeader, username: username);
    setState(() {
      _challenges = challenges;
      _isLoading = false;
      _currentPage = 1;
    });
  } catch (e) {
    setState(() => _isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    final totalPages = (_challenges.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage < _challenges.length)
        ? _currentPage * _itemsPerPage
        : _challenges.length;

    final pageChallenges = _challenges
        .sublist(startIndex, endIndex)
        .cast<ReadingChallenge>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reading Challenges'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                DropdownButtonHideUnderline(
                child: DecoratedBox(
                    decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                        BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                        ),
                    ],
                    ),
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButton<String>(
                        value: _selectedUsername,
                        hint: const Text(
                        "Search by username",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        items: _usernames
                            .map((username) => DropdownMenuItem(
                                value: username,
                                child: Text(username),
                                ))
                            .toList(),
                        onChanged: (value) {
                        setState(() => _selectedUsername = value);
                        _loadChallenges(username: value);
                        },
                        dropdownColor: Colors.deepPurple[50],
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    ),
                ),
                ),
                const SizedBox(width: 8),
                if (_selectedUsername != null)
                IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: "Clear filter",
                    onPressed: () {
                    setState(() => _selectedUsername = null);
                    _loadChallenges();
                    },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _challenges.isEmpty
                    ? const Center(child: Text("No challenges available"))
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width),
                        child: DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Description')),
                            DataColumn(label: Text('Goal Type')),
                            DataColumn(label: Text('Goal Amount')),
                            DataColumn(label: Text('Start Date')),
                            DataColumn(label: Text('End Date')),
                            DataColumn(label: Text('Progress')),
                            DataColumn(label: Text('Completed')),
                            DataColumn(label: Text('Username')),
                          ],
                          rows: pageChallenges.map((challenge) {
                            return DataRow(cells: [
                              DataCell(Text(challenge.id.toString())),
                              DataCell(Text(challenge.challengeName)),
                              DataCell(Text(challenge.description)),
                              DataCell(Text(challenge.goalType)),
                              DataCell(Text(challenge.goalAmount.toString())),
                              DataCell(Text(DateFormat('dd.MM.yyyy')
                                  .format(challenge.startDate))),
                              DataCell(Text(DateFormat('dd.MM.yyyy')
                                  .format(challenge.endDate))),
                              DataCell(Text(challenge.progress.toString())),
                              DataCell(Text(
                                  challenge.isCompleted ? "Yes" : "No")),
                              DataCell(Text(challenge.username ?? '')),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text('$_currentPage / $totalPages'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
