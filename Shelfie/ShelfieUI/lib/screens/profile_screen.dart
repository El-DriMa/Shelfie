import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:shelfie/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import '../utils/api_helpers.dart';

class ProfileScreen extends StatefulWidget {
  final String authHeader;

  ProfileScreen({required this.authHeader});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = fetchCurrentUser(widget.authHeader);
  }

  Future<void> _refreshUser() async {
    setState(() {
      userFuture = fetchCurrentUser(widget.authHeader);
    });
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
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

                SizedBox(height: 30),
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
                          builder: (_) =>
                              EditProfileScreen(
                                user: user,
                                authHeader: widget.authHeader,
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
