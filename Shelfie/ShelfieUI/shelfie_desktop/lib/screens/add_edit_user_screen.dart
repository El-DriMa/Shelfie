import 'package:flutter/material.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class AddEditUserScreen extends StatefulWidget {
  final String authHeader;
  final int? userId;

  const AddEditUserScreen({required this.authHeader, this.userId, Key? key}) : super(key: key);

  @override
  _AddEditUserScreenState createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserProvider _userProvider = UserProvider();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isActive = false;
  User? _user;

  bool get isEdit => widget.userId != null;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    if (isEdit) {
      await _loadUser(widget.userId!);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadUser(int id) async {
    try {
      _user = await _userProvider.getById(widget.authHeader, id);
      _firstNameController.text = _user!.firstName;
      _lastNameController.text = _user!.lastName;
      _isActive = _user!.isActive ?? false;
    } catch (_) {}
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    Map<String, dynamic> data;
    if (isEdit) {
      // Edit
      data = {
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "isActive": _isActive,
        "email": _user?.email,
        "username": _user?.username,
        "phoneNumber": _user?.phoneNumber,
      };
    } else {
      // Add
      data = {
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "username": _usernameController.text,
        "email": _emailController.text,
        "phoneNumber": _phoneController.text,
        "password": _passwordController.text,
        "isActive": _isActive,
      };
    }

    try {
      if (isEdit) {
        await _userProvider.updateUserById(widget.authHeader, _user!.id, data);
      } else {
        await _userProvider.createUser(widget.authHeader, data);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save user")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit User" : "Add New User"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    width: MediaQuery.of(context).size.width > 600 ? 600 : double.infinity,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                      border: Border.all(color: Colors.deepPurple.shade100),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'First name cannot be empty';
                              if (v.length > 50) return 'Maximum 50 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Last name cannot be empty';
                              if (v.length > 50) return 'Maximum 50 characters';
                              return null;
                            },
                          ),
                          if (!isEdit) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                              validator: (v) => (v == null || v.isEmpty) ? 'Username cannot be empty' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                              validator: (v) => (v == null || v.isEmpty) ? 'Email cannot be empty' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                              obscureText: true,
                              validator: (v) => (v == null || v.isEmpty) ? 'Password cannot be empty' : null,
                            ),
                          ],
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text("Active"),
                            value: _isActive,
                            onChanged: (val) {
                              setState(() => _isActive = val);
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _isSaving ? "Saving..." : (isEdit ? "Update User" : "Add User"),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
