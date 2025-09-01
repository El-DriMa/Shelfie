import 'package:flutter/material.dart';
import 'package:shelfie/screens/password_change_screen.dart';
import '../config.dart' as BaseProvider;
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/comment_provider.dart';
import '../providers/post_provider.dart';
import '../providers/reading_challenge_provider.dart';
import '../providers/review_provider.dart';
import '../providers/shelf_books_provider.dart';
import '../providers/shelf_provider.dart';
import '../providers/user_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String authHeader;

  ProfileScreen({required this.authHeader});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> userFuture;
  final _provider = UserProvider();
  Future<List<UserActivity>>? activitiesFuture;

  String selectedType = 'shelf';

  @override
  void initState() {
    super.initState();
    userFuture = _provider.getCurrentUser(widget.authHeader);
  }

  Future<void> _refreshUser() async {
    setState(() {
      userFuture = _provider.getCurrentUser(widget.authHeader);
    });
  }

  Future<void> _refreshActivities(int userId) async {
    final freshActivities = await getUserActivities(widget.authHeader, userId);
    setState(() {
      activitiesFuture = Future.value(freshActivities);
    });
  }

  String? _getUserImageUrl(String photoUrl) {
    if (photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) return photoUrl;
    String base = BaseProvider.baseUrl ?? '';
    base = base.replaceAll(RegExp(r'/api/?$'), '');
    return '$base/$photoUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: FutureBuilder<User>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Failed to load user data'));
          if (!snapshot.hasData) return Center(child: Text('No user data found'));

          final user = snapshot.data!;
          if (activitiesFuture == null) activitiesFuture = getUserActivities(widget.authHeader, user.id);
          final imageUrl = _getUserImageUrl(user.photoUrl ?? '');

          return RefreshIndicator(
            onRefresh: () => _refreshActivities(user.id),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null ? const Icon(Icons.person, size: 80, color: Color(0xFF8D6748)) : null,
                  ),
                  SizedBox(height: 16),
                  Text('${user.firstName} ${user.lastName}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('@${user.username}', style: TextStyle(color: Colors.grey[600])),
                  Divider(height: 40, thickness: 1),
                  _buildInfoRow('Email', user.email),
                  _buildInfoRow('Phone', user.phoneNumber ?? 'Not provided'),
                  SizedBox(height: 20),
                  _buildButton(Icons.edit, 'Edit Profile', Colors.deepPurple, () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditProfileScreen(authHeader: widget.authHeader, user: user)),
                    );
                    if (result == true) {
                      _refreshUser();
                      _refreshActivities(user.id);
                    }
                  }),
                  SizedBox(height: 10),
                  _buildButton(Icons.settings, 'Settings', Colors.deepPurple, () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChangePasswordScreen(authHeader: widget.authHeader, username: user.username)),
                    );
                    if (result == true) _refreshActivities(user.id);
                  }),
                  SizedBox(height: 10),
                  _buildButton(Icons.logout, 'Logout', Colors.red, () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('authToken');
                    Navigator.pushReplacementNamed(context, '/start');
                  }),
                  SizedBox(height: 30),
                  Text("Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _buildActivityTabs(),
                  SizedBox(height: 10),
                  FutureBuilder<List<UserActivity>>(
                    future: activitiesFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      List<UserActivity> activities = snapshot.data!;
                      final filteredActivities = selectedType == 'all'
                          ? activities
                          : activities.where((a) => a.type == selectedType).toList();
                      if (filteredActivities.isEmpty) return Text('No activity yet', style: TextStyle(color: Colors.grey[600]));
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: filteredActivities.length,
                        itemBuilder: (context, index) {
                          final a = filteredActivities[index];
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                a.type == 'shelf' ? Icons.book :
                                a.type == 'review' ? Icons.star :
                                a.type == 'challenge' ? Icons.flag : Icons.comment,
                                color: Colors.deepPurple,
                              ),
                              title: Text(a.description),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.email_outlined, size: 20, color: Colors.deepPurple),
          SizedBox(width: 10),
          Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildActivityTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _activityTabButton('Books', 'shelf', Icons.book),
        _activityTabButton('Reviews', 'review', Icons.star),
        _activityTabButton('Challenges', 'challenge', Icons.flag),
        _activityTabButton('Comments', 'comment', Icons.comment),
      ],
    );
  }

  Widget _activityTabButton(String label, String type, IconData icon) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.deepPurple : Colors.grey),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: isSelected ? Colors.deepPurple : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class UserActivity {
  final String type; // 'shelf', 'review', 'challenge', 'comment'
  final String description;
  final DateTime timestamp;

  UserActivity({required this.type, required this.description, required this.timestamp});
}

Future<List<UserActivity>> getUserActivities(String authHeader, int userId) async {
  final shelfProvider = ShelfProvider();
  final shelfBooksProvider = ShelfBooksProvider();
  final reviewProvider = ReviewProvider();
  final challengeProvider = ReadingChallengeProvider();
  final commentProvider = CommentProvider();
  final postProvider = PostProvider();

  List<UserActivity> activities = [];

  final shelves = (await shelfProvider.getAll(authHeader)).where((shelf) => shelf.userId == userId);
  for (var shelf in shelves) {
    final books = await shelfBooksProvider.getByShelfId(authHeader, shelf.id);
    for (var book in books) {
      activities.add(UserActivity(
        type: 'shelf',
        description: 'Added "${book.bookTitle}" to ${shelf.name}',
        timestamp: book.createdAt,
      ));
    }
  }

  final reviews = (await reviewProvider.getAll(authHeader)).where((r) => r.userId == userId);
  for (var review in reviews) {
    activities.add(UserActivity(
      type: 'review',
      description: 'Reviewed "${review.bookTitle}" (${review.rating}/5): ${review.description}',
      timestamp: DateTime.now(),
    ));
  }


  final challenges = await challengeProvider.getUserChallenges(authHeader);
  for (var c in challenges.where((ch) => ch.userId == userId)) {
    activities.add(UserActivity(
      type: 'challenge',
      description: 'Started challenge "${c.challengeName}"',
      timestamp: DateTime.now(),
    ));
  }

  final posts = await postProvider.getAll(authHeader, username: null);
  for (var post in posts) {
    final comments = await commentProvider.fetchComments(authHeader, post.id);
    for (var c in comments.where((cm) => cm.userId == userId)) {
      activities.add(UserActivity(
        type: 'comment',
        description: 'Commented on post "${post.content}": ${c.content}',
        timestamp: c.createdAt,
      ));
    }
  }

  activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return activities;
}
