import 'package:flutter/material.dart';
import 'package:trading_journal/models/user.dart';
import 'package:trading_journal/services/user_service.dart';

// Dialog for adding a new user
class AddUserDialog extends StatelessWidget {
  final UserService userService;
  final void Function(String, {bool isError}) onShowSnackBar;
  final void Function(User) onUserCreated;

  const AddUserDialog({
    super.key,
    required this.userService,
    required this.onShowSnackBar,
    required this.onUserCreated,
  });

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    Future<void> createUser() async {
      final username = usernameController.text.trim();
      final password = passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        onShowSnackBar('Please fill in all fields', isError: true);
        return;
      }

      try {
        final newUser = await userService.createUser(
          username: username,
          password: password,
        );
        if (!context.mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.pop(context);
            onShowSnackBar('User created successfully');
            onUserCreated(newUser);
          }
        });
      } catch (e) {
        if (context.mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onShowSnackBar(e.toString(), isError: true);
          });
        }
      }
    }

    return AlertDialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Add New User',
        style: Theme.of(context).textTheme.titleLarge,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(120, 48),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: createUser,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(120, 48),
              ),
              child: const Text('Add User'),
            ),
          ],
        ),
      ],
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color.fromARGB(255, 54, 52, 52),
      ),
    );
  }
}
