import 'package:flutter/material.dart';
import 'package:shelfie/providers/user_provider.dart';
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

  final _provider=UserProvider();

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile'), backgroundColor: Colors.deepPurple,foregroundColor: Colors.white, elevation: 1),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(firstNameController, 'First Name'),
            _buildTextField(lastNameController, 'Last Name'),
            _buildTextField(emailController, 'Email'),
            _buildTextField(phoneController, 'Phone'),
            _buildTextField(passwordController, 'New Password (leave empty to keep)'),
            SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child:
          ElevatedButton.icon(
            icon: Icon(Icons.edit),
            label: Text('Save changes'),
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
                final data = <String, dynamic>{};

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
                    const SnackBar(content: Text('No changes to save')),
                  );
                  return;
                }

                try {
                  await _provider.updateUser(widget.authHeader, widget.user.id, data);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update user'), backgroundColor: Colors.red),
                  );
                }
              }
            ),
        ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 14),
      ],
    );
  }

}
