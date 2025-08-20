import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../models/genre.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import '../providers/genre_provider.dart';
import 'comments_screen.dart';

class PostsScreen extends StatefulWidget {
  final String authHeader;
  const PostsScreen({required this.authHeader, Key? key}) : super(key: key);

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final PostProvider _postProvider = PostProvider();
  final UserProvider _userProvider = UserProvider();
  final GenreProvider _genreProvider = GenreProvider();

  List<Post> _posts = [];
  List<String> _usernames = [];
  List<Genre> _genres = [];
  String? _selectedUsername;
  int? _selectedGenreId;
  int? _selectedState;
  bool _isLoading = true;

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  final Map<int, String> postStates = {
    0: 'Draft',
    1: 'Published',
    2: 'Archived',
    3: 'Deleted',
  };

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadPosts();
  }

  Future<void> _loadFilters() async {
    var users = await _userProvider.getAll(widget.authHeader);
    var genres = await _genreProvider.getAll(widget.authHeader);
    setState(() {
      _usernames = users.map((u) => u.username!).toList();
      _genres = genres;
    });
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final genreName = _selectedGenreId != null ? _genres.firstWhere((g) => g.id == _selectedGenreId!).name : null;
      final posts = await _postProvider.getAll(
        widget.authHeader,
        username: _selectedUsername,
        postState: _selectedState,
        genreName: genreName,
      );

      setState(() {
        _posts = posts;
        _currentPage = 1;
      });
    } catch (_) {
      setState(() => _posts = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePost(int id) async {
    try {
      await _postProvider.deletePost(widget.authHeader, id);
      _loadPosts();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete post")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_posts.length / _itemsPerPage).ceil().clamp(1, 999);
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage < _posts.length) ? _currentPage * _itemsPerPage : _posts.length;
    final pagePosts = _posts.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Posts"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
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
                            _loadPosts();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: DropdownButton<int>(
                          value: _selectedGenreId,
                          hint: const Text("Filter by genre"),
                          items: _genres.map((g) => DropdownMenuItem<int>(
                            value: g.id,
                            child: Text(g.name),
                          )).toList(),
                          onChanged: (val) {
                            setState(() => _selectedGenreId = val);
                            _loadPosts();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: DropdownButton<int>(
                          value: _selectedState,
                          hint: const Text("Filter by state"),
                          items: postStates.entries
                              .map((e) => DropdownMenuItem<int>(
                                    value: e.key,
                                    child: Text(e.value),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() => _selectedState = val);
                            _loadPosts();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                if (_selectedUsername != null || _selectedGenreId != null || _selectedState != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.deepPurple),
                    onPressed: () {
                      setState(() {
                        _selectedUsername = null;
                        _selectedGenreId = null;
                        _selectedState = null;
                      });
                      _loadPosts();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                      ? const Center(child: Text("No posts available"))
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
                                DataColumn(label: Text("Genre")),
                                DataColumn(label: Text("Created At")),
                                DataColumn(label: Text("State")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: pagePosts.map((p) {
                                return DataRow(cells: [
                                  DataCell(Text(p.id.toString())),
                                  DataCell(Text(p.username ?? "")),
                                  DataCell(Text(p.content)),
                                  DataCell(Text(p.genreName ?? "")),
                                  DataCell(Text(DateFormat('dd.MM.yyyy HH:mm').format(p.createdAt))),
                                  DataCell(Text(p.state)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.comment, color: Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CommentsScreen(
                                                authHeader: widget.authHeader,
                                                postId: p.id,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("Confirm deletion"),
                                              content: const Text("Are you sure you want to delete this post?"),
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
                                            _deletePost(p.id);
                                          }
                                        },
                                      ),
                                    ],
                                  )),
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
