import 'package:flutter/material.dart';
import 'package:shelfie/providers/notification_provider.dart';
import '../models/myNotifications.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import 'comments_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String authHeader;

  NotificationsScreen({required this.authHeader});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<MyNotifications>> _notificationsFuture;
  final _provider = NotificationProvider();
  final _postProvider = PostProvider();

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _provider.getUserNotifications(widget.authHeader);
  }

  Future<void> markAsRead(int id) async {
    await _provider.updateNotification(widget.authHeader, id);
  }

  Future<List<MyNotifications>> fetchNotifications() {
    return _provider.getUserNotifications(widget.authHeader);
  }

  Future<void> openPost(int postId) async {
    final post = await _postProvider.getById(widget.authHeader, postId);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentsScreen(
          post: post,
          authHeader: widget.authHeader,
        ),
      ),
    );
  }

  void onNotificationTap(MyNotifications notification) async {
    if (!notification.isRead) {
      await markAsRead(notification.id);
      setState(() {
        _notificationsFuture = fetchNotifications();
      });
    }
    openPost(notification.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<MyNotifications>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return FutureBuilder<Post>(
                future: _postProvider.getById(widget.authHeader, notification.postId),
                builder: (context, snapshot) {
                  String postTitle = 'Loading post...';
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    postTitle = snapshot.data!.content ?? 'Post';
                    if(postTitle.length > 50) {
                      postTitle = postTitle.substring(0, 50) + '...';
                    }
                  } else if (snapshot.hasError) {
                    postTitle = 'Error loading post';
                  }

                  return InkWell(
                    onTap: () => onNotificationTap(notification),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: notification.isRead ? Colors.white : Colors.deepPurple[50],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.commentText,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: notification.isRead ? Colors.grey[800] : Colors.deepPurple[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'From: ${notification.fromUserName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'On post: $postTitle',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.deepPurple[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
