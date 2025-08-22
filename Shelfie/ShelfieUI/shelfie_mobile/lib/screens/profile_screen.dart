import 'package:flutter/material.dart';
import 'package:shelfie/screens/password_change_screen.dart';
import '../config.dart' as BaseProvider;
import '../models/user.dart';
import 'package:shelfie/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
        elevation: 1,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: FutureBuilder<User>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load user data'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No user data found'));
          }

          final user = snapshot.data!;
          final imageUrl = _getUserImageUrl(user!.photoUrl ?? '');
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 36),

                CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null
                      ? const Icon(Icons.person, size: 80, color: Color(0xFF8D6748))
                      : null,
                ),
                SizedBox(height: 16),
                Text('${user.firstName} ${user.lastName}',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Text('@${user.username}',
                    style: TextStyle(color: Colors.grey[600])),

                Divider(height: 40, thickness: 1),

                _buildInfoRow('Email', user.email),
                _buildInfoRow('Phone', user.phoneNumber ?? 'Not provided'),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text('Do you really want to delete your profile?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await _provider.deleteUser(widget.authHeader,user.id);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('authToken');
                          Navigator.pushReplacementNamed(context, '/start');
                        }
                      },
                      child: const Text(
                        'Delete Profile',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),


                SizedBox(height: 10),
                Text('Update your profile or change your account settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14)),

                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child:
                  ElevatedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            authHeader: widget.authHeader,
                            user: user,
                          ),
                        ),
                      );

                      if (result == true) {
                        _refreshUser();
                      }
                    },
                  ),
                ),

                SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child:
                  ElevatedButton.icon(
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChangePasswordScreen(
                                authHeader: widget.authHeader,
                                username: user.username,
                        ),
                        ),
                      );
                      if (result == true) {
                        _refreshUser();
                      }
                    },
                  ),
                ),

                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child:
                  ElevatedButton.icon(
                    icon: Icon(Icons.logout),
                    label: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('authToken');
                      Navigator.pushReplacementNamed(context, '/start');
                    },
                  ),
                ),
              ],
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
          Text('$title: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
              child: Text(value,
                  style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
