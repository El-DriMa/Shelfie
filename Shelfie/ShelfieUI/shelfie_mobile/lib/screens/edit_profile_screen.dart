import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import '../providers/base_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  final String authHeader;

  const EditProfileScreen({required this.user, required this.authHeader, Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late User _user;

  File? _selectedImage;
  String? _existingPhotoUrl;
  final _provider = UserProvider();
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    _existingPhotoUrl = _user.photoUrl;
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg','jpeg','png','gif','bmp','webp'],
      allowMultiple: false,
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  String? _getImageUrl(String photoUrl) {
    if (photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('http')) return photoUrl;

    String base = BaseProvider.baseUrl ?? '';
    base = base.replaceAll(RegExp(r'/api/?$'), '');

    return '$base/$photoUrl';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final data = <String, dynamic>{};
    if (firstNameController.text.trim().isNotEmpty) data['firstName'] = firstNameController.text.trim();
    if (lastNameController.text.trim().isNotEmpty) data['lastName'] = lastNameController.text.trim();
    if (emailController.text.trim().isNotEmpty) data['email'] = emailController.text.trim();
    if (phoneController.text.trim().isNotEmpty) data['phoneNumber'] = phoneController.text.trim();
    data['photoUrl'] = _user.photoUrl;

    try {
      if (data.isNotEmpty) {
        await _provider.updateUser(widget.authHeader, widget.user.id, data);
      }
      if (_selectedImage != null) {
        await _provider.uploadPhoto(widget.authHeader, widget.user.id, _selectedImage!);
      }

      _user = await _provider.getById(widget.authHeader, _user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      backgroundColor: Colors.deepPurple[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_existingPhotoUrl != null
                        ? NetworkImage(_getImageUrl(_existingPhotoUrl!)!)
                        : const AssetImage("assets/avatar.jpg") as ImageProvider),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedImage != null || _existingPhotoUrl != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                                _existingPhotoUrl = null;
                                _user.photoUrl = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 22),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(firstNameController, 'First Name', required: true),
              _buildTextField(lastNameController, 'Last Name', required: true),
              _buildTextField(emailController, 'Email', required: true),
              _buildTextField(phoneController, 'Phone (optional)', required: false),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          validator: (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return '$label is required';
            }

            if (label == 'Email' && value != null && value.trim().isNotEmpty) {
              final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!regex.hasMatch(value.trim())) {
                return 'Invalid email format (must be like name@example.com)';
              }
            }

            if (label.startsWith('Phone') && value != null && value.trim().isNotEmpty) {
              final regex = RegExp(r'^[0-9]+$');
              if (!regex.hasMatch(value.trim())) {
                return 'Phone must contain only digits';
              }
              if (value.trim().length < 6 || value.trim().length > 15) {
                return 'Phone must be between 6 and 15 digits';
              }
            }

            return null;
          },
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: !required
                ? IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  controller.clear();
                });
              },
            )
                : null,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
