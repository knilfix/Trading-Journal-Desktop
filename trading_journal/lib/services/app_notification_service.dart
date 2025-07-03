import 'package:flutter/material.dart';

class AppNotificationService {
  // Basic SnackBar notification
  static void showSnackBar({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    int durationInSeconds = 3,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: durationInSeconds),
      ),
    );
  }

  // Success notification
  static void showSuccess(
    BuildContext context,
    String message,
  ) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.green.shade800,
    );
  }

  // Error notification
  static void showError(
    BuildContext context,
    String message,
  ) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.red.shade800,
    );
  }

  // Warning notification
  static void showWarning(
    BuildContext context,
    String message,
  ) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.orange.shade800,
      textColor: Colors.black87,
    );
  }

  // Info notification
  static void showInfo(
    BuildContext context,
    String message,
  ) {
    showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.blue.shade800,
    );
  }
}
