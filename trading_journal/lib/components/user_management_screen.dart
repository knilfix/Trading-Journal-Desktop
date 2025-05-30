import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends State<UserManagementScreen> {
  final UserService _userService = UserService.instance;
  User? _selectedUser;
  bool _isEditing = false;
  final _editController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _selectUser(User user) {
    setState(() {
      _selectedUser = user;
      _isEditing = false;
      _editController.text = user.username;
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _editController.text = _selectedUser!.username;
      }
    });
  }

  Future<void> _saveUser() async {
    if (_editController.text.trim().isEmpty) return;

    try {
      final updatedUser = User(
        id: _selectedUser!.id,
        username: _editController.text.trim(),
        password: _selectedUser!.password,
        createdAt: _selectedUser!.createdAt,
      );

      final success = await _userService.updateUser(
        updatedUser,
      );

      if (success) {
        setState(() {
          _selectedUser = updatedUser;
          _isEditing = false;
        });
        _showSnackBar('User updated successfully');
      } else {
        _showSnackBar(
          'Failed to update user',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> _deleteUser(int id) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    await _userService.deleteUser(id);
    setState(() {
      _selectedUser = null;
    });
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete User'),
            content: Text(
              'Are you sure you want to delete ${_selectedUser!.username}?',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _toggleActiveUser() async {
    if (_userService.activeUser == _selectedUser) {
      _userService.clearActiveUser();
    } else {
      await _userService.setActiveUser(_selectedUser!);
    }
    setState(() {});
  }

  void _showAddUserDialog() {
    if (_userService.users.length >= 4) {
      _showSnackBar(
        'User limit reached (Max: 4)',
        isError: true,
      );
      return;
    }

    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(
          context,
        ).dialogTheme.backgroundColor, // Matches app theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Add New User',
          style: Theme.of(
            context,
          ).textTheme.titleLarge, // Matches app typography
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: usernameController,
              label: 'Username',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface, // Match theme
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  minimumSize: const Size(120, 48),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _createUser(
                  context,
                  usernameController,
                  passwordController,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary, // Match theme
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimary, // Text color
                  minimumSize: const Size(120, 48),
                ),
                child: const Text('Add User'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createUser(
    BuildContext context,
    TextEditingController usernameController,
    TextEditingController passwordController,
  ) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar(
        'Please fill in all fields',
        isError: true,
      );
      return;
    }

    try {
      final newUser = await _userService.createUser(
        username: username,
        password: password,
      );
      if (!mounted) return;

      setState(() {
        _selectedUser = newUser;
      });

      // Use post-frame callback to safely interact with UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
          _showSnackBar('User created successfully');
        }
      });
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSnackBar(e.toString(), isError: true);
        });
      }
    }
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 54, 52, 52),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Panel - User List
          Container(
            width: 300,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.black12),
              ),
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildUserList()),
                _buildAddUserButton(),
              ],
            ),
          ),
          // Right Panel - User Details
          Expanded(
            child: _selectedUser == null
                ? _buildEmptyState()
                : _buildUserDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(
            Icons.people,
            size: 28,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          const Text(
            'Users',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_userService.users.length}/4',
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

  Widget _buildUserList() {
    if (_userService.users.isEmpty) {
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
      itemCount: _userService.users.length,
      itemBuilder: (context, index) {
        final user = _userService.users[index];
        final isActive = _userService.activeUser == user;
        final isSelected = _selectedUser == user;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            selected: isSelected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              backgroundColor: isActive
                  ? Colors.green
                  : Colors.grey[300],
              child: Text(
                user.username[0].toUpperCase(),
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.username,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: isActive
                ? const Text(
                    'Active User',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: () => _deleteUser(user.id!),
            ),
            onTap: () => _selectUser(user),
          ),
        );
      },
    );
  }

  Widget _buildAddUserButton() {
    final canAddUser = _userService.users.length < 4;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: canAddUser ? _showAddUserDialog : null,
          icon: const Icon(Icons.add),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Select a user to view details',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails() {
    final isActive =
        _userService.activeUser == _selectedUser;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isActive
                        ? Colors.green
                        : Colors.grey[300],
                    child: Text(
                      _selectedUser!.username[0]
                          .toUpperCase(),
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : Colors.grey[600],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _isEditing
                            ? TextField(
                                controller: _editController,
                                decoration:
                                    const InputDecoration(
                                      border:
                                          OutlineInputBorder(),
                                      labelText: 'Username',
                                    ),
                              )
                            : Text(
                                _selectedUser!.username,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(
                              top: 4,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius:
                                  BorderRadius.circular(12),
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
              _buildDetailRow(
                'Password',
                _selectedUser!.password,
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                'Created',
                _selectedUser!.createdAt.toString(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isEditing
                          ? _saveUser
                          : _toggleEditMode,
                      icon: Icon(
                        _isEditing
                            ? Icons.save
                            : Icons.edit,
                      ),
                      label: Text(
                        _isEditing ? 'Save' : 'Edit',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleActiveUser,
                      icon: Icon(
                        isActive
                            ? Icons.person_remove
                            : Icons.person_add,
                      ),
                      label: Text(
                        isActive
                            ? 'Deactivate'
                            : 'Activate',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
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
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
