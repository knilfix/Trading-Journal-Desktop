import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:trading_journal/services/user_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');

  late Directory tempDir;
  late UserService userService;

  setUp(() async {
    // Create a fake temp directory
    tempDir = await Directory.systemTemp.createTemp('test_users');

    // Intercept platform channel call to path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return tempDir.path;
          }
          return null;
        });

    userService = UserService.instance;

    // Clean previous users if any (test setup)
    userService.clearActiveUser();
    userService.users.clear();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('saveToJson creates file with user data', () async {
    await userService.createUser(username: 'Mark', password: 'abc123');
    await userService.saveToJson();

    final file = File(p.join(tempDir.path, 'TradingJournal', 'users.json'));
    final content = await file.readAsString();

    expect(content.contains('Mark'), true);
  });

  test('loadFromJson loads previously saved users', () async {
    await userService.createUser(username: 'Alice', password: 'xyz789');
    await userService.saveToJson();

    userService.clearActiveUser();
    // ✅ works fine

    await userService.loadFromJson();

    expect(userService.users.any((u) => u.username == 'Alice'), true);
  });
}
