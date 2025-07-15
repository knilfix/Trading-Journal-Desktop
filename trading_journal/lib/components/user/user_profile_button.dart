import 'package:flutter/material.dart';
import 'package:trading_journal/services/user_service.dart';
import '../../screens/user_profile.dart';
import '../../models/user.dart';

class UserProfileButton extends StatefulWidget {
  final bool isExpanded;
  final ThemeData theme;
  final VoidCallback? onTap;

  const UserProfileButton({
    super.key,
    required this.isExpanded,
    required this.theme,
    this.onTap,
  });

  @override
  State<UserProfileButton> createState() => _UserProfileButtonState();
}

class _UserProfileButtonState extends State<UserProfileButton> {
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = UserService.instance;
    _userService.addListener(_onUserChanged); // Add listener
  }

  @override
  void dispose() {
    _userService.removeListener(_onUserChanged); // Remove listener
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) {
      setState(() {}); // Trigger rebuild when user changes
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the UserService instance

    final activeUser = _userService.activeUser;

    return GestureDetector(
      onTap:
          widget.onTap ??
          () {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'User Profile',
              barrierColor: Colors.black.withOpacity(0.6),
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return const SizedBox.shrink();
              },
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                    final curvedAnimation = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    );

                    return Transform.scale(
                      scale: curvedAnimation.value,
                      child: Opacity(
                        opacity: animation.value,
                        child: Center(
                          child: Material(
                            type: MaterialType.transparency,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 500,
                                maxHeight: 700,
                              ),
                              margin: const EdgeInsets.all(24),
                              child: UserProfile(userId: activeUser?.id),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
            );
          },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.symmetric(
          horizontal: widget.isExpanded ? 16 : 4,
          vertical: 2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isExpanded ? 16 : 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.surfaceContainerHighest.withOpacity(
            0.3,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.theme.colorScheme.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: activeUser != null
            ? _buildUserProfile(activeUser, widget.theme)
            : _buildLoginPrompt(widget.theme),
      ),
    );
  }

  Widget _buildUserProfile(User user, ThemeData theme) {
    final initials = getInitials(user.username);

    return AnimatedCrossFade(
      duration: const Duration(
        milliseconds: 180,
      ), // Sync with Sidebar content animation
      crossFadeState: widget.isExpanded
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Consistent padding
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.username,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Online',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 0, // Minimal space for chevron
              child: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                size: 20,
              ),
            ),
          ],
        ),
      ),
      secondChild: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                initials,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(ThemeData theme) {
    return widget.isExpanded
        ? Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Login',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                size: 20,
              ),
            ],
          )
        : Center(
            child: Icon(
              Icons.person_outline,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          );
  }

  String getInitials(String username) {
    final parts = username.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (username.isNotEmpty) {
      return username.substring(0, 1).toUpperCase();
    }
    return '';
  }
}
