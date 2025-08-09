import 'package:flutter/material.dart';
import 'package:shelfie/screens/add_new_post_screen.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import 'comments_screen.dart';


class PostsScreen extends StatefulWidget {
  final String genreName;
  final int genreId;
  final String authHeader;

  const PostsScreen({
    super.key,
    required this.genreName,
    required this.genreId,
    required this.authHeader,
  });

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

const Map<int, Color> postStateColors = {
  0: Colors.grey,        // Draft
  1: Colors.green,       // Published
  2: Colors.orange,      // Archived
  3: Colors.red,         // Deleted
};

const Map<int, String> postStateLabels = {
  0: 'Draft',
  1: 'Published',
  2: 'Archived',
  3: 'Deleted',
};

class _PostsScreenState extends State<PostsScreen> {
  late Future<List<Post>> posts;
  bool isMyPosts = false;

  final _provider = PostProvider();
  final _userProvider = UserProvider();

  void loadPosts() async {
    setState(() {
      if (isMyPosts) {
        posts = _provider.getUserPosts(widget.authHeader, widget.genreId);
      } else {
        posts = _provider.getByGenre(widget.authHeader, widget.genreId);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime.toLocal());

    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.genreName} discussions'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.deepPurple[50],
      body:
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Toggle buttons on the left
                TextButton(
                  onPressed: () {
                    if (isMyPosts) {
                      isMyPosts = false;
                      loadPosts();
                    }
                  },
                  child: Text(
                    'All Posts',
                    style: TextStyle(
                      color: !isMyPosts ? Colors.deepPurple : Colors.grey,
                      fontWeight: !isMyPosts ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (!isMyPosts) {
                      isMyPosts = true;
                      loadPosts();
                    }
                  },
                  child: Text(
                    'My Posts',
                    style: TextStyle(
                      color: isMyPosts ? Colors.deepPurple : Colors.grey,
                      fontWeight: isMyPosts ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Spacer(),
                Icon(Icons.add, color: Colors.deepPurple),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    final user = await _userProvider.getCurrentUser(widget.authHeader);

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddNewPostScreen(
                          authHeader: widget.authHeader,
                          userId: user.id,
                          genreId: widget.genreId,
                        ),
                      ),
                    );

                    if (result == true) {
                      setState(() {
                        posts = _provider.getByGenre(widget.authHeader, widget.genreId);
                      });
                    }
                  },
                  child: const Text(
                    'Add New Post',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Post>>(
                future: posts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load posts'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No posts found'));
                  }

                  final postList = snapshot.data!
                      .where((p) => p.state != 'Deleted')
                      .toList();
                  return ListView.builder(
                    itemCount: postList.length,
                    itemBuilder: (context, index) {
                      final post = postList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentsScreen(
                                    post: post,
                                    authHeader: widget.authHeader,
                                  ),
                                ),
                              );

                              if (result == true) {
                                setState(() {
                                  posts = _provider.getByGenre(widget.authHeader, widget.genreId);
                                });
                              }
                            },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 30,
                                      child: Icon(Icons.person, size: 50),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      post.username ?? 'User',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      getTimeAgo(post.createdAt),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    Spacer(),
                                    if (isMyPosts)
                                      Builder(
                                        builder: (context) {
                                          print('post.state: ${post.state}');
                                          final stateMap = {
                                            'Draft': 0,
                                            'Published': 1,
                                            'Archived': 2,
                                            'Deleted': 3,
                                          };
                                          final int stateValue = stateMap[post.state] ?? 0;
                                          return Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: postStateColors[stateValue]?.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  postStateLabels[stateValue] ?? 'Unknown',
                                                  style: TextStyle(
                                                    color: postStateColors[stateValue] ?? Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              PopupMenuButton<int>(
                                                icon: const Icon(Icons.edit, color: Colors.deepPurple),
                                                onSelected: (newValue) async {
                                                  await _provider.updatePostState(widget.authHeader, post.id, newValue);
                                                  loadPosts();
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(value: 0, child: Text('Draft')),
                                                  const PopupMenuItem(value: 1, child: Text('Published')),
                                                  const PopupMenuItem(value: 2, child: Text('Archived')),
                                                  const PopupMenuItem(value: 3, child: Text('Deleted')),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),

                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post.content,
                                  style: const TextStyle(fontSize: 15),
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
          ],
        ),
      ),
    );
  }
}
