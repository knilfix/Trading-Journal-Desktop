import 'package:flutter/material.dart';
import '../services/app_notification_service.dart';

class NotificationExamplePage extends StatefulWidget {
  const NotificationExamplePage({super.key});

  @override
  State<NotificationExamplePage> createState() =>
      _NotificationExamplePageState();
}

class _NotificationExamplePageState
    extends State<NotificationExamplePage> {
  final TextEditingController _messageController =
      TextEditingController(
        text: 'This is a sample notification message',
      );

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Examples'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Notification Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Basic SnackBar'),
            _buildButton(
              'Show Default SnackBar',
              () => AppNotificationService.showSnackBar(
                context: context,
                message: _messageController.text,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Predefined Types'),
            _buildButton(
              'Success Notification',
              () => AppNotificationService.showSuccess(
                context,
                _messageController.text,
              ),
              color: Colors.green,
            ),
            _buildButton(
              'Error Notification',
              () => AppNotificationService.showError(
                context,
                _messageController.text,
              ),
              color: Colors.red,
            ),
            _buildButton(
              'Warning Notification',
              () => AppNotificationService.showWarning(
                context,
                _messageController.text,
              ),
              color: Colors.orange,
            ),
            _buildButton(
              'Info Notification',
              () => AppNotificationService.showInfo(
                context,
                _messageController.text,
              ),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(text),
      ),
    );
  }
}
