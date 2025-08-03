import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shelfie/utils/api_helpers.dart';

import '../config.dart';
import '../models/post.dart';

Future<Post> addNewPost(String authHeader, String content, int userId, int genreId) async {
  final uri = Uri.parse('$baseUrl/Post');

  final response = await http.post(
    uri,
    headers: {
      'authorization': authHeader,
      'content-type': 'application/json',
    },
    body: jsonEncode({
      'content': content,
      'userId': userId,
      'genreId': genreId,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    try {
      final data = jsonDecode(response.body);
      return Post.fromJson(data);
    } catch (e) {
      print('JSON parsing error: $e');
      throw Exception('Failed to parse Post response');
    }
  } else {
    print('Add new post failed: ${response.body}');
    throw Exception('Failed to add new Post');
  }
}

class AddNewPostScreen extends StatefulWidget {
  final int userId;
  final int genreId;
  final String authHeader;

  const AddNewPostScreen({
    super.key,
    required this.authHeader,
    required this.userId,
    required this.genreId,
  });

  @override
  State<AddNewPostScreen> createState() => _AddNewPostScreenState();
}

class _AddNewPostScreenState extends State<AddNewPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool isLoading = false;

  Future<void> submitPost() async {
    final content = _contentController.text.trim();
    print('SubmitPost called with content: "$content"');
    print('UserId: ${widget.userId}, GenreId: ${widget.genreId}');

    if (content.isEmpty) {
      print('Content is empty, aborting submit');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content cannot be empty')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final post = await addNewPost(
        widget.authHeader,
        content,
        widget.userId,
        widget.genreId,
      );
      print('Post added successfully: ${post.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post added successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('Error adding post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add post: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Post'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Write your post below:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.deepPurple[600],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 8,
                minLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Enter your post content here...',
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isLoading ? null : submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                'Submit',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.deepPurple[50],
    );
  }
}