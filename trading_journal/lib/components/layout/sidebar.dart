import 'package:flutter/material.dart';
import 'dart:math' show pi;
import '../../models/navigation_item.dart';
import '../user/user_profile_button.dart';

class Sidebar extends StatelessWidget {
  final bool isExpanded;
  final int selectedIndex;
  final List<NavigationItem> navigationItems;
  final Function(int) onItemSelected;
  final VoidCallback onToggleSidebar;
  final ThemeData theme;

  const Sidebar({
    super.key,
    required this.isExpanded,
    required this.selectedIndex,
    required this.navigationItems,
    required this.onItemSelected,
    required this.onToggleSidebar,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isExpanded ? 300 : 60, // Dynamic width for responsiveness
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildNavigationItems(),
          AnimatedCrossFade(
            duration: const Duration(
              milliseconds: 180,
            ), // Faster to sync with width
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: UserProfileButton(isExpanded: true, theme: theme),
            secondChild: UserProfileButton(isExpanded: false, theme: theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 180),
        crossFadeState: isExpanded
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstChild: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Journal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Pro Version',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: onToggleSidebar,
                icon: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0, // 0.5 turn = 180 degrees
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.menu,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        secondChild: Center(
          child: Tooltip(
            message: 'Toggle Sidebar',
            child: IconButton(
              onPressed: onToggleSidebar,
              icon: Transform.rotate(
                angle: isExpanded ? pi : 0,
                child: Icon(
                  Icons.menu,
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItems() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: isExpanded ? 8 : 4, // Try reducing from 12/16 to 8/4
        ),
        itemCount: navigationItems.length,
        itemBuilder: (context, index) {
          final item = navigationItems[index];
          final isSelected = selectedIndex == index;

          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: isExpanded ? 0 : 4,
              vertical: 2,
            ),
            child: Material(
              color: Colors.transparent,
              child: !isExpanded
                  ? Tooltip(
                      message: item.label,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onItemSelected(index),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isExpanded ? 16 : 0,
                            vertical: isExpanded ? 12 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.2),
                                  )
                                : null,
                          ),
                          child: isExpanded
                              ? Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? item.selectedIcon
                                          : item.icon,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: Text(
                                        item.label,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.onSurface,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    size: 24,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                  ),
                                ),
                        ),
                      ),
                    )
                  : InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onItemSelected(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isExpanded ? 16 : 0,
                          vertical: isExpanded ? 12 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.2,
                                  ),
                                )
                              : null,
                        ),
                        child: isExpanded
                            ? Row(
                                children: [
                                  Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 16),
                                  Flexible(
                                    child: Text(
                                      item.label,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurface,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  size: 24,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.7,
                                        ),
                                ),
                              ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
