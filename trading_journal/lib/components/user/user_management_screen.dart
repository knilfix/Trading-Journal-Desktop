import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import 'user_details_panel.dart';
import 'user_list_sidebar.dart';

// Main screen orchestrating the components
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService.instance;
  User? _selectedUser;

  void _selectUser(User user) {
    setState(() {
      _selectedUser = user;
    });
  }

  void _clearSelectedUser() {
    setState(() {
      _selectedUser = null;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          UserListSidebar(
            userService: _userService,
            selectedUser: _selectedUser,
            onUserSelected: _selectUser,
            onShowSnackBar: _showSnackBar,
            onUserDeleted: _clearSelectedUser,
          ),
          Expanded(
            child: UserDetailsPanel(
              userService: _userService,
              selectedUser: _selectedUser,
              onUserUpdated: _selectUser,
              onShowSnackBar: _showSnackBar,
              onUserDeleted: _clearSelectedUser,
            ),
          ),
        ],
      ),
    );
  }
}
