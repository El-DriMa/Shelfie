import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/comment.dart';
import '../providers/comment_provider.dart';
import '../providers/user_provider.dart';

class CommentsScreen extends StatefulWidget {
  final String authHeader;
  final int postId;
  const CommentsScreen({required this.authHeader, required this.postId, Key? key}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final CommentProvider _commentProvider = CommentProvider();
  final UserProvider _userProvider = UserProvider();

  List<Comment> _comments = [];
  List<String> _usernames = [];
  String? _selectedUsername;
  bool _isLoading = true;

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadComments();
  }

  Future<void> _loadFilters() async {
    var users = await _userProvider.getAll(widget.authHeader);
    setState(() {
      _usernames = users.map((u) => u.username as String).toList();
    });
  }

  Future<void> _loadComments({String? username}) async {
    setState(() => _isLoading = true);
    try {
      var comments = await _commentProvider.fetchComments(widget.authHeader, widget.postId);

      if (username != null) {
        comments = comments.where((c) => c.username == username).toList();
      }

      setState(() {
        _comments = comments;
        _currentPage = 1;
      });
    } catch (_) {} finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteComment(int id) async {
    try {
      await _commentProvider.deleteComment(widget.authHeader, id);
      _loadComments(username: _selectedUsername);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete comment")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_comments.length / _itemsPerPage).ceil().clamp(1, 999);
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        (_currentPage * _itemsPerPage < _comments.length) ? _currentPage * _itemsPerPage : _comments.length;
    final pageComments = _comments.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      title: const Text("Comments", style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
    ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButtonHideUnderline(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButton<String>(
                        value: _selectedUsername,
                        hint: const Text("Filter by username", style: TextStyle(fontWeight: FontWeight.bold)),
                        items: _usernames.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (val) {
                          setState(() => _selectedUsername = val);
                          _loadComments(username: val);
                        },
                        dropdownColor: Colors.deepPurple[50],
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                if (_selectedUsername != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.deepPurple),
                    tooltip: "Clear username filter",
                    onPressed: () {
                      setState(() => _selectedUsername = null);
                      _loadComments();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? const Center(child: Text("No comments available"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                            child: DataTable(
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text("ID")),
                                DataColumn(label: Text("User")),
                                DataColumn(label: Text("Content")),
                                DataColumn(label: Text("Created At")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: pageComments.map((c) {
                                return DataRow(cells: [
                                  DataCell(Text(c.id.toString())),
                                  DataCell(Text(c.username ?? "")),
                                  DataCell(Text(c.content)),
                                  DataCell(Text(DateFormat('dd.MM.yyyy HH:mm').format(c.createdAt))),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Confirm deletion"),
                                            content: const Text("Are you sure you want to delete this comment?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          _deleteComment(c.id);
                                        }
                                      },
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                ),
                Text('$_currentPage / $totalPages'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
