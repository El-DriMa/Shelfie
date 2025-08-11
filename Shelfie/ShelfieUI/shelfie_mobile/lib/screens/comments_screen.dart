import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shelfie/providers/comment_provider.dart';
import '../config.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../providers/user_provider.dart';


class CommentsScreen extends StatefulWidget {
  final Post post;
  final String authHeader;

  const CommentsScreen({
    Key? key,
    required this.post,
    required this.authHeader,
  }) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late Future<List<Comment>> commentsFuture;
  Comment? replyingToComment;
  final TextEditingController replyController = TextEditingController();
  final _provider = CommentProvider();
  final _userProvider = UserProvider();

  Map<int, List<Comment>> buildRepliesMap(List<Comment> comments) {
    final map = <int, List<Comment>>{};
    for (var comment in comments) {
      if (comment.parentCommentId != null) {
        map.putIfAbsent(comment.parentCommentId!, () => []).add(comment);
      }
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    commentsFuture = _provider.fetchComments(widget.authHeader, widget.post.id);
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime.toLocal());
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }



  Future<void> sendReply() async {
    final content = replyController.text.trim();
    if (content.isEmpty) return;
    int? parentCommentId = replyingToComment?.id;
    int postId = widget.post.id;
    final user = await _userProvider.getCurrentUser(widget.authHeader);
    await _provider.addComment(widget.authHeader, postId, user.id, content, parentCommentId);

    replyController.clear();
    setState(() {
      replyingToComment = null;
      commentsFuture = _provider.fetchComments(widget.authHeader, postId);
    });
  }

  Widget buildComments(List<Comment> comments) {
    final repliesMap = buildRepliesMap(comments);
    final mainComments = comments.where((c) => c.parentCommentId == null).toList();

    return ListView.builder(
      itemCount: mainComments.length,
      itemBuilder: (context, index) {
        final comment = mainComments[index];
        return CommentWithRepliesWidget(
          comment: comment,
          replies: repliesMap[comment.id] ?? [],
          onReply: () {
            setState(() {
              replyingToComment = comment;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Comments'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
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
                        widget.post.username ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getTimeAgo(widget.post.createdAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post.content,
                    style: const TextStyle(fontSize: 15),
                  ),

                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Comment>>(
                future: commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load comments'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No comments yet'));
                  }
                  return buildComments(snapshot.data!);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (replyingToComment != null)
                    Row(
                      children: [
                        Text('Replying to @${replyingToComment!.username}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              replyingToComment = null;
                            });
                          },
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyController,
                          decoration: InputDecoration(
                            hintText: replyingToComment == null ? 'Reply to post...' : 'Reply to comment...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: sendReply,
                      ),
                    ],
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

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onReply;

  const CommentWidget({Key? key, required this.comment, this.onReply}) : super(key: key);

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime.toLocal());
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                radius: 20,
                child: Icon(Icons.person, size: 30),
              ),
              const SizedBox(width: 8),
              Text(
                comment.username ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                _getTimeAgo(comment.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14),
          ),
          if (comment.parentCommentId == null && onReply != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: onReply,
                child: Text(
                  'Reply',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CommentWithRepliesWidget extends StatelessWidget {
  final Comment comment;
  final List<Comment> replies;
  final VoidCallback onReply;

  const CommentWithRepliesWidget({
    Key? key,
    required this.comment,
    required this.replies,
    required this.onReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentWidget(
          comment: comment,
          onReply: comment.parentCommentId == null ? onReply : null,
        ),
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              children: replies
                  .map((r) => CommentWithRepliesWidget(
                comment: r,
                replies: [],
                onReply: onReply,
              ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
