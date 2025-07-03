import 'package:flutter/material.dart';

class ModernFloatingTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<TabItem> tabs;

  const ModernFloatingTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4), // Reduced from 16
      padding: const EdgeInsets.all(3), // Reduced from 4
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(
          6,
        ), // Reduced from 12
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              (0.2 * 255).round(),
            ), // Reduced opacity
            blurRadius: 4, // Reduced from 8
            offset: const Offset(
              0,
              1,
            ), // Reduced from (0, 2)
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 3,
            ), // Reduced from (20, 10)
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 67, 70, 72)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                6,
              ), // Reduced from 8
            ),
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: 10, // Reduced from 18
                    color: isSelected
                        ? Colors.white
                        : Colors.grey[400],
                  ),
                  const SizedBox(
                    width: 2,
                  ), // Reduced from 8
                  Text(
                    tab.title,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.grey[400],
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 8, // Reduced from 14
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TabItem {
  final IconData icon;
  final String title;

  const TabItem({required this.icon, required this.title});
}
