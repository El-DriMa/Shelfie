import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shelfie/providers/user_provider.dart';
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

  File? _selectedImage;
  String? _existingPhotoUrl;
  final _provider = UserProvider();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    _existingPhotoUrl = widget.user.photoUrl;
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

  Future<void> _saveProfile() async {
    setState(() { _isSaving = true; });

    final data = <String, dynamic>{};
    if (firstNameController.text.trim().isNotEmpty) data['firstName'] = firstNameController.text.trim();
    if (lastNameController.text.trim().isNotEmpty) data['lastName'] = lastNameController.text.trim();
    if (emailController.text.trim().isNotEmpty) data['email'] = emailController.text.trim();
    if (phoneController.text.trim().isNotEmpty) data['phoneNumber'] = phoneController.text.trim();

    try {
      if (data.isNotEmpty) {
        await _provider.updateUser(widget.authHeader, widget.user.id, data);
      }
      if (_selectedImage != null) {
        await _provider.uploadPhoto(widget.authHeader, widget.user.id, _selectedImage!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isSaving = false; });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_existingPhotoUrl != null && _existingPhotoUrl!.isNotEmpty
                      ? NetworkImage("${BaseProvider.baseUrl}${_existingPhotoUrl!}") as ImageProvider
                      : const AssetImage("assets/default_profile.png")),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
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
                )
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(firstNameController, 'First Name'),
            _buildTextField(lastNameController, 'Last Name'),
            _buildTextField(emailController, 'Email'),
            _buildTextField(phoneController, 'Phone'),
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
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
