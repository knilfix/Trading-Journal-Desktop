import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/portfolio_screen.dart';
import '../components/user/user_profile_button.dart';
import '../components/tradesScreen/account_selection_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isExpanded = true;
  late AnimationController _animationController;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      screen: const DashboardScreen(),
    ),
    NavigationItem(
      icon: Icons.show_chart_outlined,
      selectedIcon: Icons.show_chart,
      label: 'Trades',
      screen: const AccountSelectionScreen(),
      isExpanded: false,
    ),
    NavigationItem(
      icon: Icons.pie_chart_outline,
      selectedIcon: Icons.pie_chart,
      label: 'Portfolio',
      screen: const PortfolioScreen(),
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Analytics',
      screen: const AnalyticsScreen(),
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
      screen: const SettingsScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      if (index == 1) {
        // Check if the selected index is 1 (AccountSelectionScreen)
        _isExpanded = false;
      } else {
        _isExpanded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentScreen =
        _navigationItems[_selectedIndex].screen;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // Sidebar Navigation
          SizedBox(
            width: _isExpanded ? 280 : 80,

            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1A1A)
                    : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: theme.dividerColor.withOpacity(
                      0.1,
                    ),
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
                  // Header - Responsive Layout
                  Container(
                    height: 80,
                    padding: EdgeInsets.symmetric(
                      horizontal: _isExpanded ? 20 : 12,
                    ),
                    child: _isExpanded
                        ? Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme
                                          .colorScheme
                                          .primary,
                                      theme
                                          .colorScheme
                                          .secondary,
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                ),
                                child: const Icon(
                                  Icons.trending_up,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Text(
                                      'Trading Journal',
                                      style: theme
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            color: theme
                                                .colorScheme
                                                .onSurface,
                                          ),
                                      overflow: TextOverflow
                                          .ellipsis,
                                    ),
                                    Text(
                                      'Pro Version',
                                      style: theme
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .secondary,
                                          ),
                                      overflow: TextOverflow
                                          .ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: IconButton(
                                  onPressed: _toggleSidebar,
                                  icon: Icon(
                                    Icons.menu_open,
                                    color: theme
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: IconButton(
                              onPressed: _toggleSidebar,
                              icon: Icon(
                                Icons.menu,
                                color: theme
                                    .colorScheme
                                    .onSurface,
                              ),
                              iconSize: 24,
                            ),
                          ),
                  ),

                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: _isExpanded ? 12 : 8,
                      ),
                      itemCount: _navigationItems.length,
                      itemBuilder: (context, index) {
                        final item =
                            _navigationItems[index];
                        final isSelected =
                            _selectedIndex == index;

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: _isExpanded ? 0 : 4,
                            vertical: 2,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                  _onPageChanged(index);
                                });
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal:
                                          _isExpanded
                                          ? 16
                                          : 8,
                                      vertical: 12,
                                    ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme
                                            .colorScheme
                                            .primary
                                            .withOpacity(
                                              0.1,
                                            )
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(
                                        12,
                                      ),
                                  border: isSelected
                                      ? Border.all(
                                          color: theme
                                              .colorScheme
                                              .primary
                                              .withOpacity(
                                                0.2,
                                              ),
                                        )
                                      : null,
                                ),
                                child: _isExpanded
                                    ? Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? item.selectedIcon
                                                : item.icon,
                                            color:
                                                isSelected
                                                ? theme
                                                      .colorScheme
                                                      .primary
                                                : theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(
                                                        0.7,
                                                      ),
                                            size: 24,
                                          ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Flexible(
                                            child: Text(
                                              item.label,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color:
                                                    isSelected
                                                    ? theme
                                                          .colorScheme
                                                          .primary
                                                    : theme
                                                          .colorScheme
                                                          .onSurface,
                                                fontWeight:
                                                    isSelected
                                                    ? FontWeight
                                                          .w600
                                                    : FontWeight
                                                          .normal,
                                              ),
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: Icon(
                                          isSelected
                                              ? item.selectedIcon
                                              : item.icon,
                                          color: isSelected
                                              ? theme
                                                    .colorScheme
                                                    .primary
                                              : theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(
                                                      0.7,
                                                    ),
                                          size: 24,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  UserProfileButton(
                    isExpanded: _isExpanded,
                    theme: theme,

                    // onTap: () {} // Optional custom tap handler
                  ), // User Profile Section - Only show when expanded
                ],
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(
                children: [
                  if (_selectedIndex != 1)
                    // Top Bar
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A1A1A)
                            : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor
                                .withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _navigationItems[_selectedIndex]
                                  .label,
                              style: theme
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                    color: theme
                                        .colorScheme
                                        .onSurface,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Notification Icon
                          IconButton(
                            onPressed: () {},
                            icon: Stack(
                              children: [
                                Icon(
                                  Icons
                                      .notifications_outlined,
                                  color: theme
                                      .colorScheme
                                      .onSurface,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration:
                                        const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape
                                              .circle,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Content Area
                  Expanded(child: currentScreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget screen;
  final bool isExpanded;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.screen,
    this.isExpanded = false,
  });
}
