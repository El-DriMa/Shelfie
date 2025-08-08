import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelfie/screens/add_new_post_screen.dart';
import 'package:shelfie/utils/api_helpers.dart';
import '../models/post.dart';
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

class _PostsScreenState extends State<PostsScreen> {
  late Future<List<Post>> posts;
  bool isMyPosts = false;

  void loadPosts() async {
    setState(() {
      if (isMyPosts) {
        posts = fetchUserPosts(widget.authHeader, widget.genreId);
      } else {
        posts = fetchPosts(widget.authHeader, widget.genreId);
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
                Spacer(), // Pushes the next widgets to the right
                Icon(Icons.add, color: Colors.deepPurple),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    final user = await fetchCurrentUser(widget.authHeader);

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
                        posts = fetchPosts(widget.authHeader, widget.genreId);
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

                  final postList = snapshot.data!;
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
                                  posts = fetchPosts(widget.authHeader, widget.genreId);
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
