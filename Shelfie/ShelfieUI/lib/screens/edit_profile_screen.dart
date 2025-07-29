import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shelfie/config.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final String authHeader;

  EditProfileScreen({required this.user, required this.authHeader});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    passwordController = TextEditingController();
  }

  Future<void> updateUser(int id) async {
    Map<String, dynamic> data = {};

    if (firstNameController.text.trim().isNotEmpty) {
      data['firstName'] = firstNameController.text.trim();
    }
    if (lastNameController.text.trim().isNotEmpty) {
      data['lastName'] = lastNameController.text.trim();
    }
    if (emailController.text.trim().isNotEmpty) {
      data['email'] = emailController.text.trim();
    }
    if (phoneController.text.trim().isNotEmpty) {
      data['phoneNumber'] = phoneController.text.trim();
    }
    if (passwordController.text.isNotEmpty) {
      data['password'] = passwordController.text;
    }

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No changes to save')),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/User/$id'),
      headers: {
        'authorization': widget.authHeader,
        'content-type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(firstNameController, 'First Name'),
            _buildTextField(lastNameController, 'Last Name'),
            _buildTextField(emailController, 'Email'),
            _buildTextField(phoneController, 'Phone'),
            _buildTextField(passwordController, 'New Password (leave empty to keep)'),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () => updateUser(widget.user.id),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: label.toLowerCase().contains('password'),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
