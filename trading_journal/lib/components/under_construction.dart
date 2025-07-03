import 'package:flutter/material.dart';

class UnderConstructionScreen extends StatelessWidget {
  final String pageName;
  final String message;
  final Icon pageIcon;

  const UnderConstructionScreen({
    super.key,
    required this.pageName,
    required this.message,
    required this.pageIcon,
  });

  @override
  Widget build(BuildContext context) {
    final String overview = "$pageName Overview";
    final String comingSoon = "$message coming soon";

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            pageIcon,
            const SizedBox(height: 16),
            //receive a overview desctiption
            Text(
              overview,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            //coming soon
            Text(comingSoon),
          ],
        ),
      ),
    );
  }
}
