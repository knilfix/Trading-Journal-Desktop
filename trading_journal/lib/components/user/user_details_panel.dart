import 'package:flutter/material.dart';
import 'package:trading_journal/models/user.dart';
import 'package:trading_journal/services/user_service.dart';

class UserDetailsPanel extends StatefulWidget {
  final UserService userService;
  final User? selectedUser;
  final void Function(User) onUserUpdated;
  final void Function(String, {bool isError}) onShowSnackBar;
  final VoidCallback onUserDeleted;

  const UserDetailsPanel({
    super.key,
    required this.userService,
    required this.selectedUser,
    required this.onUserUpdated,
    required this.onShowSnackBar,
    required this.onUserDeleted,
  });

  @override
  State<UserDetailsPanel> createState() => _UserDetailsPanelState();
}

class _UserDetailsPanelState extends State<UserDetailsPanel> {
  bool _isEditing = false;
  final _editController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _editController.text = widget.selectedUser!.username;
      }
    });
  }

  Future<void> _saveUser() async {
    if (_editController.text.trim().isEmpty) return;

    try {
      final updatedUser = User(
        id: widget.selectedUser!.id,
        username: _editController.text.trim(),
        password: widget.selectedUser!.password,
        createdAt: widget.selectedUser!.createdAt,
      );

      final success = await widget.userService.updateUser(updatedUser);

      if (success) {
        setState(() {
          _isEditing = false;
        });
        widget.onUserUpdated(updatedUser);
        widget.onShowSnackBar('User updated successfully');
      } else {
        widget.onShowSnackBar('Failed to update user', isError: true);
      }
    } catch (e) {
      widget.onShowSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> _toggleActiveUser() async {
    if (widget.userService.activeUser == widget.selectedUser) {
      widget.userService.clearActiveUser();
      widget.onUserDeleted();
    } else {
      await widget.userService.setActiveUser(widget.selectedUser!);
      widget.onUserUpdated(widget.userService.activeUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedUser == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select a user to view details',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final isActive = widget.userService.activeUser == widget.selectedUser;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isActive ? Colors.green : Colors.grey[300],
                    child: Text(
                      widget.selectedUser!.username[0].toUpperCase(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isEditing
                            ? TextField(
                                controller: _editController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Username',
                                ),
                              )
                            : Text(
                                widget.selectedUser!.username,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Active User',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildDetailRow('Password', widget.selectedUser!.password),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Created',
                widget.selectedUser!.createdAt.toString(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isEditing ? _saveUser : _toggleEditMode,
                      icon: Icon(_isEditing ? Icons.save : Icons.edit),
                      label: Text(_isEditing ? 'Save' : 'Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleActiveUser,
                      icon: Icon(
                        isActive ? Icons.person_remove : Icons.person_add,
                      ),
                      label: Text(isActive ? 'Deactivate' : 'Activate'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isActive
                            ? Colors.orange
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
