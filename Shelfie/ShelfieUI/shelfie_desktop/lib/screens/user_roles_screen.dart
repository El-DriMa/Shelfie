import 'package:flutter/material.dart';
import '../models/role.dart';
import '../models/userRole.dart';
import '../providers/role_provider.dart';
import '../providers/user_role_provider.dart';

class UserRolesScreen extends StatefulWidget {
  final String authHeader;
  final int userId;
  final String username;

  const UserRolesScreen({
    required this.authHeader,
    required this.userId,
    required this.username,
    Key? key,
  }) : super(key: key);

  @override
  _UserRolesScreenState createState() => _UserRolesScreenState();
}

class _UserRolesScreenState extends State<UserRolesScreen> {
  final RoleProvider _roleProvider = RoleProvider();
  final UserRoleProvider _userRoleProvider = UserRoleProvider();

  List<Role> _allRoles = [];
  List<UserRole> _userRoles = [];
  Role? _selectedRole;
  UserRole? _selectedUserRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoading = true);
    try {
      final roles = await _roleProvider.getAll(widget.authHeader);
      final userRoles = await _userRoleProvider.getAllForUser(
        widget.authHeader,
        userId: widget.userId,
      );
      setState(() {
        _allRoles = roles;
        _userRoles = userRoles;
        _selectedRole = null;
        _selectedUserRole = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load roles: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _addOrUpdateRole() async {
    if (_selectedRole == null) return;
    try {
      if (_selectedUserRole != null) {
        await _userRoleProvider.updateRole(
          widget.authHeader,
          _selectedUserRole!.id,
          {"userId": widget.userId, "roleId": _selectedRole!.id},
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Role updated successfully"), backgroundColor: Colors.green),
        );
      } else {
        await _userRoleProvider.createRole(widget.authHeader, {
          "userId": widget.userId,
          "roleId": _selectedRole!.id,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Role added successfully"), backgroundColor: Colors.green),
        );
      }
      await _loadRoles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _removeRole(int userRoleId) async {
    if (_userRoles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User must have at least one role"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      await _userRoleProvider.deleteRole(widget.authHeader, userRoleId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Role removed successfully"),
          backgroundColor: Colors.green,
        ),
      );
      await _loadRoles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Roles for ${widget.username}"),backgroundColor: Colors.deepPurple,foregroundColor: Colors.white,),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: DropdownButton<Role>(
                            isExpanded: true,
                            value: _selectedRole,
                            hint: const Text("Select role"),
                            items: _allRoles.map((role) {
                              return DropdownMenuItem<Role>(
                                value: role,
                                child: Text(role.name, style: const TextStyle(fontSize: 16)),
                              );
                            }).toList(),
                            onChanged: (role) {
                              setState(() => _selectedRole = role);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addOrUpdateRole,
                          child: Text(_selectedUserRole != null ? "Update" : "Add",
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _userRoles.length,
                        itemBuilder: (context, index) {
                          final userRole = _userRoles[index];
                          final isSelected = _selectedUserRole?.id == userRole.id;
                          return Card(
                            color: isSelected ? Colors.deepPurple[50] : null,
                            child: ListTile(
                              title: Text(userRole.roleName, style: const TextStyle(fontSize: 16)),
                              onTap: () {
                                setState(() {
                                  _selectedUserRole = userRole;
                                  _selectedRole = _allRoles.firstWhere(
                                    (r) => r.name == userRole.roleName,
                                    orElse: () => _allRoles.first,
                                  );
                                });
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeRole(userRole.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
