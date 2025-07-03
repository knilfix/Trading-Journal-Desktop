import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserService extends ChangeNotifier {
  //singleton pattern
  static final UserService instance =
      UserService._internal();

  UserService._internal() {
    // Create default test user
    _createDefaultTestUser();
  }

  final int delayDuration = 100;

  //in memory storage
  final List<User> _users = [];
  User? _activeUser;
  int _nextId = 1;

  User? get activeUser => _activeUser;
  List<User> get users => List.unmodifiable(_users);

  void _createDefaultTestUser() {
    final testUser = User(
      id: _nextId++,
      username: 'test_user',
      password: 'test123',
      createdAt: DateTime.now().toIso8601String(),
    );

    _users.add(testUser);
    setActiveUser(testUser);
    debugPrint('Default test User created: $testUser');
  }

  Future<void> setActiveUser(User user) async {
    // Verify user exists in our list
    if (_users.any((u) => u.id == user.id)) {
      _activeUser = user;
      notifyListeners();
      debugPrint('Active user set to: ${user.username}');
    } else {
      throw Exception('User not found in system');
    }
  }

  void clearActiveUser() {
    _activeUser = null;
    notifyListeners();
    debugPrint('Active user cleared');
  }

  //CRUD Operations
  Future<User> createUser({
    required String password,
    required String username,
  }) async {
    // Simulate network delay
    await Future.delayed(
      Duration(milliseconds: delayDuration),
    );

    //check if username already exists
    if (_users.any((user) => user.username == username)) {
      throw Exception('Username already taken');
    }

    final user = User(
      id: _nextId++,
      password: password,
      username: username,
      createdAt: DateTime.now().toIso8601String(),
    );

    _users.add(user);
    notifyListeners();
    debugPrint('Added user: ${user.username}');
    return user;
  }

  Future<List<User>> getAllUsers() async {
    await Future.delayed(
      Duration(milliseconds: delayDuration),
    );

    return _users;
  }

  Future<User?> getUserById(int id) async {
    await Future.delayed(
      Duration(milliseconds: delayDuration),
    );
    return _users.firstWhere(
      (user) => user.id == id,
      orElse: () => throw Exception('User not found'),
    );
  }

  Future<bool> updateUser(User updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final index = _users.indexWhere(
      (user) => user.id == updatedUser.id,
    );
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    //check if were deleting the active user
    if (_activeUser?.id == id) {
      clearActiveUser();
    }

    final initialLength = _users.length;
    _users.removeWhere((user) => user.id == id);
    if (_users.length < initialLength) {
      notifyListeners();
      return true;
    }
    return false;
  }

  // Sample data generator
  Future<void> generateSampleUsers() async {
    final sampleUsers = [
      {'password': 'password123', 'username': 'John Doe'},
      {'password': 'password456', 'username': 'Jane Smith'},
    ];

    for (var userData in sampleUsers) {
      await createUser(
        password: userData['password']!,
        username: userData['username']!,
      );
    }
  }
}
