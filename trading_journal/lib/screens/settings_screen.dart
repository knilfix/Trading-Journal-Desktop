import 'package:flutter/material.dart';
import 'package:trading_journal/components/user/user_management_screen.dart';
import 'package:trading_journal/screens/settings/accounts_settings.dart';
import 'package:trading_journal/screens/settings/appearance_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;

  final List<SettingsMenuItem> _menuItems = [
    SettingsMenuItem(
      icon: Icons.person_outline,
      label: 'Profile',
      screen: const UserManagementScreen(),
    ),
    SettingsMenuItem(
      icon: Icons.account_balance_wallet_outlined,
      label: 'Accounts',
      screen: const AccountManagementScreen(),
    ),
    SettingsMenuItem(
      icon: Icons.data_usage,
      label: 'Data Management',
      screen: const Center(child: Text('Data Settings')),
    ),
    SettingsMenuItem(
      icon: Icons.palette_outlined,
      label: 'Appearance',
      screen: const Center(child: AppearanceSettings()),
    ),
    SettingsMenuItem(
      icon: Icons.info_outline,
      label: 'About',
      screen: const Center(child: Text('About')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Left Panel - Settings Menu
        Container(
          width: 250,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
          ),
          child: ListView.builder(
            itemCount: _menuItems.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              final isSelected = _selectedIndex == index;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.2,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Right Panel - Content Area
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: _menuItems[_selectedIndex].screen,
          ),
        ),
      ],
    );
  }
}

class SettingsMenuItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const SettingsMenuItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
