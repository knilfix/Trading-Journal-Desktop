import 'package:flutter/material.dart';
import '../services/user_service.dart'; // Adjust path as needed
import '../models/user.dart'; // Adjust path as needed

class UserProfile extends StatefulWidget {
  final int? userId; // Pass the current user's ID

  const UserProfile({super.key, this.userId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final UserService _userService = UserService.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers for editing
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  User? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      // Priority 1: Use explicitly passed userId
      if (widget.userId != null) {
        _currentUser = await _userService.getUserById(
          widget.userId!,
        );
      }
      // Priority 2: Fallback to active user
      else {
        _currentUser = UserService.instance.activeUser;
        if (_currentUser == null) {
          throw Exception('No active user available');
        }
      }

      _usernameController.text = _currentUser!.username;
      _passwordController.text = _currentUser!.password;
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() ||
        _currentUser == null) {
      return;
    }

    try {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      final updatedUser = User(
        id: _currentUser!.id,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        createdAt: _currentUser!.createdAt,
      );

      final success = await _userService.updateUser(
        updatedUser,
      );

      if (success) {
        setState(() {
          _currentUser = updatedUser;
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _errorMessage = null;
      // Reset controllers to original values
      if (_currentUser != null) {
        _usernameController.text = _currentUser!.username;
        _passwordController.text = _currentUser!.password;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button and edit toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? 'Edit Profile' : 'Profile',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isEditing && _currentUser != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        icon: Icon(
                          Icons.edit_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        tooltip: 'Edit Profile',
                      ),
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.7),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Profile Content
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _currentUser == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 48,
                            color: theme
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No user found',
                            style:
                                theme.textTheme.bodyLarge,
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: theme
                                        .colorScheme
                                        .error,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Large Profile Avatar
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  theme.colorScheme.primary,
                              child: Text(
                                _currentUser!
                                        .username
                                        .isNotEmpty
                                    ? _currentUser!
                                          .username[0]
                                          .toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Error message display
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                12,
                              ),
                              decoration: BoxDecoration(
                                color: theme
                                    .colorScheme
                                    .errorContainer,
                                borderRadius:
                                    BorderRadius.circular(
                                      8,
                                    ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: theme
                                      .colorScheme
                                      .onErrorContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Username Field
                          _buildProfileField(
                            context,
                            icon: Icons.person_outlined,
                            title: 'Username',
                            controller: _usernameController,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Username is required';
                              }
                              return null;
                            },
                            readOnly: !_isEditing,
                          ),

                          const SizedBox(height: 16),

                          // Password Field
                          _buildProfileField(
                            context,
                            icon: Icons.lock_outlined,
                            title: 'Password',
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            readOnly: !_isEditing,
                            obscureText: !_isEditing,
                          ),

                          const SizedBox(height: 16),

                          // Created At (Read-only)
                          _buildInfoCard(
                            context,
                            icon: Icons.schedule_outlined,
                            title: 'Member Since',
                            value: _formatDateTime(
                              _currentUser!.createdAt ?? '',
                            ),
                          ),

                          const SizedBox(height: 16),

                          // User ID (Read-only)
                          _buildInfoCard(
                            context,
                            icon: Icons.badge_outlined,
                            title: 'User ID',
                            value: '#${_currentUser!.id}',
                          ),

                          const SizedBox(height: 24),

                          // Action Buttons
                          if (_isEditing) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isSaving
                                        ? null
                                        : _cancelEditing,
                                    child: const Text(
                                      'Cancel',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isSaving
                                        ? null
                                        : _saveChanges,
                                    child: _isSaving
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child:
                                                CircularProgressIndicator(
                                                  strokeWidth:
                                                      2,
                                                ),
                                          )
                                        : const Text(
                                            'Save Changes',
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(
    BuildContext context, {
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool readOnly = false,
    bool obscureText = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              8,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: TextFormField(
              controller: controller,
              validator: validator,
              readOnly: readOnly,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: readOnly ? null : 'Enter $title',
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return isoString;
    }
  }
}
