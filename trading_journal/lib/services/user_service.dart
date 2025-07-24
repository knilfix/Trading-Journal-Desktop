import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import 'package:trading_journal/interfaces/persistable_service.dart';

/// Service for managing users, including authentication, persistence, and active user selection.
class UserService extends ChangeNotifier implements PersistableService {
  //singleton pattern
  static final UserService instance = UserService._internal();
  static const String _userFileName = 'users.json';

  /// Private constructor for singleton pattern.
  UserService._internal();

  /// Initializes the service by loading users from persistent storage.
  Future<void> initialize() async {
    try {
      await loadFromJson();
      if (_users.isEmpty) {
        // Optionally create a default user here if needed
      }
    } catch (e) {
      // Optionally create a default user here if needed
    }
  }

  /// In-memory list of all users.
  final List<User> _users = [];

  /// The currently active user, or null if none is active.
  User? _activeUser;

  /// Returns the currently active user, or null if none is active.
  User? get activeUser => _activeUser;

  /// Returns an unmodifiable list of all users.
  List<User> get users => List.unmodifiable(_users);

  /// Returns a File handle for the users.json file in the app's documents directory.
  Future<File> _getUserFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/TradingJournal');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File('${appDir.path}/$_userFileName');
  }

  /// Sets the given user as the active user and persists the change.
  Future<void> setActiveUser(User user) async {
    if (_users.any((u) => u.id == user.id)) {
      // Set all users to inactive
      for (int i = 0; i < _users.length; i++) {
        _users[i] = _users[i].copyWith(isActive: false);
      }

      // Update selected user to active
      final index = _users.indexWhere((u) => u.id == user.id);
      _users[index] = _users[index].copyWith(isActive: true);
      _activeUser = _users[index];

      notifyListeners();
      await saveToJson(); // Persist change
    } else {
      throw Exception('User not found in system');
    }
  }

  /// Clears the active user and persists the change.
  void clearActiveUser() {
    if (_activeUser != null) {
      final index = _users.indexWhere((u) => u.id == _activeUser!.id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isActive: false);
      }
    }

    _activeUser = null;
    notifyListeners();
    saveToJson(); // Persist change
  }

  /// Returns the next available user ID.
  int _getNextId() {
    if (_users.isEmpty) return 1;
    return _users.map((u) => u.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Creates a new user with the given username and password.
  /// Throws if the username is already taken.
  Future<User> createUser({
    required String password,
    required String username,
  }) async {
    if (_users.any((user) => user.username == username)) {
      throw Exception('Username already taken');
    }

    final user = User(
      id: _getNextId(),
      password: password,
      username: username,
      createdAt: DateTime.now().toIso8601String(),
    );

    _users.add(user);
    await saveToJson();
    notifyListeners();
    return user;
  }

  /// Returns a list of all users (async).
  Future<List<User>> getAllUsers() async {
    return List.unmodifiable(_users);
  }

  /// Returns the user with the given ID, or throws if not found.
  Future<User?> getUserById(int id) async {
    return _users.firstWhere(
      (user) => user.id == id,
      orElse: () => throw Exception('User not found'),
    );
  }

  /// Updates the given user in the list and persists the change.
  Future<bool> updateUser(User updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      await saveToJson();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Deletes the user with the given ID. If the active user is deleted, clears the active user.
  Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    //check if were deleting the active user
    if (_activeUser?.id == id) {
      clearActiveUser();
    }

    final initialLength = _users.length;
    _users.removeWhere((user) => user.id == id);
    if (_users.length < initialLength) {
      await saveToJson();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Loads users from persistent storage (users.json).
  @override
  Future<void> loadFromJson() async {
    final file = await _getUserFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      _users.clear();
      for (var userMap in jsonList) {
        _users.add(User.fromMap(userMap));
      }

      // Restore active user
      final activeUser = _users.where((u) => u.isActive).toList();
      _activeUser = activeUser.isNotEmpty ? activeUser.first : null;

      notifyListeners();
    }
  }

  /// Returns a File handle for the users.json file (public version).
  Future<File> getUserFile() async {
    return await _getUserFile();
  }

  /// Saves the current list of users to persistent storage (users.json).
  @override
  Future<void> saveToJson() async {
    final file = await _getUserFile();
    final userList = users.map((u) => u.toMap()).toList();
    final jsonContents = jsonEncode(userList);
    await file.writeAsString(jsonContents);
  }
}
