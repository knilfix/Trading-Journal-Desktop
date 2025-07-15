import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/user_service.dart';
import 'add_user_dialog.dart';

// Sidebar containing user list and add user button
class UserListSidebar extends StatelessWidget {
  final UserService userService;
  final User? selectedUser;
  final void Function(User) onUserSelected;
  final void Function(String, {bool isError}) onShowSnackBar;
  final VoidCallback onUserDeleted;

  const UserListSidebar({
    super.key,
    required this.userService,
    required this.selectedUser,
    required this.onUserSelected,
    required this.onShowSnackBar,
    required this.onUserDeleted,
  });

  Future<bool> _showDeleteConfirmation(BuildContext context, User user) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete User'),
            content: Text('Are you sure you want to delete ${user.username}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteUser(BuildContext context, int id) async {
    final confirmed = await _showDeleteConfirmation(
      context,
      userService.users.firstWhere((u) => u.id == id),
    );
    if (!confirmed) return;

    await userService.deleteUser(id);
    onUserDeleted();
  }

  void _showAddUserDialog(BuildContext context) {
    if (userService.users.length >= 4) {
      onShowSnackBar('User limit reached (Max: 4)', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        userService: userService,
        onShowSnackBar: onShowSnackBar,
        onUserCreated: onUserSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildUserList(context)),
          _buildAddUserButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.people, size: 28, color: Colors.blue),
          const SizedBox(width: 12),
          const Text(
            'Users',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${userService.users.length}/4',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    if (userService.users.isEmpty) {
      return const Center(
        child: Text(
          'No users yet\nAdd your first user below',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: userService.users.length,
      itemBuilder: (context, index) {
        final user = userService.users[index];
        final isActive = userService.activeUser == user;
        final isSelected = selectedUser == user;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            selected: isSelected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              backgroundColor: isActive ? Colors.green : Colors.grey[300],
              child: Text(
                user.username[0].toUpperCase(),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: isActive
                ? const Text(
                    'Active User',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteUser(context, user.id!),
            ),
            onTap: () => onUserSelected(user),
          ),
        );
      },
    );
  }

  Widget _buildAddUserButton(BuildContext context) {
    final canAddUser = userService.users.length < 4;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: canAddUser ? () => _showAddUserDialog(context) : null,
          icon: const Icon(Icons.add),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
