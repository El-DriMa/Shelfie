import 'package:flutter/material.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'add_edit_user_screen.dart';
import 'change_user_password_screen.dart';
import 'user_roles_screen.dart';

class UsersScreen extends StatefulWidget {
  final String authHeader;
  const UsersScreen({required this.authHeader, Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserProvider _userProvider = UserProvider();
  List<User> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortOrder = 'A-Z';
  User? _currentUser;

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _currentUser = await _userProvider.getCurrentUser(widget.authHeader);
    _loadUsers();
  }
  Future<void> _loadUsers() async {
    try {
      var users = await _userProvider.getAll(widget.authHeader);
      setState(() {
        _users = users;
        _sortUsers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _sortUsers() {
    if (_sortOrder == 'A-Z') {
      _users.sort((a, b) => a.username.compareTo(b.username));
    } else {
      _users.sort((a, b) => b.username.compareTo(a.username));
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() => _isLoading = true);
    try {
      var users = await _userProvider.searchUsers(widget.authHeader, query);
      setState(() {
        _users = users;
        _isLoading = false;
        _currentPage = 1;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_users.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (_currentPage * _itemsPerPage < _users.length)
        ? _currentPage * _itemsPerPage
        : _users.length;
    final pageUsers = _users.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by username',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _searchUsers(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: _sortOrder,
                        items: const [
                          DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                          DropdownMenuItem(value: 'Z-A', child: Text('Z-A')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortOrder = value!;
                            _sortUsers();
                            _currentPage = 1;
                          });
                        },
                        dropdownColor: Colors.deepPurple[50],
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditUserScreen(
                            authHeader: widget.authHeader),
                      ),
                    ).then((value) {
                      if (value == true) {
                        _loadUsers();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 22),
                  ),
                  child: const Text(
                    "Add new User",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width),
                        child: DataTable(
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Username')),
                            DataColumn(label: Text('First Name')),
                            DataColumn(label: Text('Last Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Last Login')),
                            DataColumn(label: Text('Phone')),
                            DataColumn(label: Text('Active')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: pageUsers.map((user) {
                            return DataRow(cells: [
                              DataCell(Text(user.id.toString())),
                              DataCell(Text(user.username)),
                              DataCell(Text(user.firstName)),
                              DataCell(Text(user.lastName)),
                              DataCell(Text(user.email)),
                              DataCell(Text(user.lastLoginAt != null
                                  ? DateFormat('dd.MM.yyyy HH:mm')
                                      .format(user.lastLoginAt!)
                                  : '')),
                              DataCell(Text(user.phoneNumber ?? '')),
                              DataCell(Text(user.isActive == true ? 'Yes' : 'No')),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddEditUserScreen(
                                            authHeader: widget.authHeader,
                                            userId: user.id,
                                          ),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          _loadUsers();
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                      icon: const Icon(Icons.vpn_key, color: Colors.red),
                                      tooltip: "Change Password",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChangeUserPasswordScreen(
                                              authHeader: widget.authHeader, 
                                              userId: user.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                   if (user.username != _currentUser?.username)
                                    IconButton(
                                      icon: const Icon(Icons.security, color: Colors.blue),
                                      tooltip: "Manage Roles",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => UserRolesScreen(
                                              authHeader: widget.authHeader,
                                              userId: user.id,
                                              username: user.username,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this user?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Delete')),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await _userProvider.deleteUser(widget.authHeader, user.id);
                                      
                                      if (user.id == _currentUser?.id) {
                                        Navigator.of(context).pushReplacementNamed('/login');
                                      } else {
                                        _loadUsers();
                                      }
                                    }
                                  },
                                ),

                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text('$_currentPage / $totalPages'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
