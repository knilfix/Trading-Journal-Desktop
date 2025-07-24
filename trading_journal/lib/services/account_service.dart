import 'package:flutter/foundation.dart';
import 'package:trading_journal/services/trade_service.dart';
import '../models/account.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service for managing accounts, including CRUD operations, persistence, and active account selection for the active user.
class AccountService extends ChangeNotifier {
  /// Singleton instance of AccountService.
  static final AccountService instance = AccountService._internal();

  /// Reference to the UserService singleton for active user tracking.
  final UserService _userService = UserService.instance;

  /// Returns the currently active user, or null if none is active.
  User? get activeUser => _userService.activeUser;

  /// In-memory list of all accounts.
  final List<Account> _accounts = [];

  /// Notifier for the list of accounts for the active user.
  final ValueNotifier<List<Account>> accountsListenable = ValueNotifier([]);

  /// The next account ID to assign.
  int _nextId = 1;

  /// The currently active account, or null if none is active.
  Account? _activeAccount;
  Account? get activeAccount {
    try {
      return _accounts.firstWhere(
        (a) => a.id == _activeAccount?.id && a.userId == activeUser?.id,
      );
    } catch (e) {
      return null;
    }
  }

  static const String _accountFileName = 'accounts.json';

  /// Private constructor for singleton pattern. Sets up listener for user changes and loads accounts from storage.
  AccountService._internal() {
    _userService.addListener(_onUserChanged);
    loadFromJson();
  }

  /// Called when the active user changes. Clears the active account and notifies listeners.
  void _onUserChanged() {
    // Deactivate all accounts when user changes
    for (int i = 0; i < _accounts.length; i++) {
      if (_accounts[i].isActive) {
        _accounts[i] = _accounts[i].copyWith(isActive: false);
      }
    }
    _activeAccount = null;
    _updateListeners();
    TradeService.instance.notifyListeners();
  }

  /// Sets the account with the given ID as the active account.
  Future<void> setActiveAccount(int accountId) async {
    // First verify we have an active user
    if (activeUser == null) {
      throw StateError('Cannot set active account without an active user');
    }

    // Find the account and verify ownership
    final accountIndex = _accounts.indexWhere(
      (a) => a.id == accountId && a.userId == activeUser!.id,
    );

    if (accountIndex == -1) {
      throw StateError('Account not found or not owned by current user');
    }

    // Deactivate all accounts (including those from other users)
    for (int i = 0; i < _accounts.length; i++) {
      if (_accounts[i].isActive) {
        _accounts[i] = _accounts[i].copyWith(isActive: false);
      }
    }

    // Activate the selected account
    _accounts[accountIndex] = _accounts[accountIndex].copyWith(isActive: true);
    _activeAccount = _accounts[accountIndex];

    await saveToJson();
    notifyListeners();
  }

  /// Clears the active account and notifies listeners.
  void clearActiveAccount() {
    _activeAccount = null;
    notifyListeners();
    debugPrint('Active account cleared');
  }

  /// Updates listeners and the accountsListenable notifier with accounts for the active user.
  void _updateListeners() {
    debugPrint("_updateListeners() called"); // Debug
    accountsListenable.value = List.unmodifiable(
      _accounts.where((a) => a.userId == activeUser?.id),
    );
    notifyListeners();
  }

  /// Returns a list of accounts for the active user.
  List<Account> get accounts =>
      List.unmodifiable(_accounts.where((a) => a.userId == activeUser?.id));

  /// Returns a File handle for the accounts.json file in the app's documents directory.
  Future<File> _getAccountFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/TradingJournal');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File('${appDir.path}/$_accountFileName');
  }

  /// Creates a new account for the active user.
  Future<Account?> createAccount({
    required double balance,
    required AccountType accountType,
    required String name,
  }) async {
    if (activeUser == null) {
      return null;
    }

    if (balance < 0) {
      return null;
    }

    final double target = balance * 1.08;
    final double maxLoss = balance * 0.9;

    final account = Account(
      id: _nextId++,
      userId: activeUser!.id!,
      name: name,
      balance: balance,
      startBalance: balance,
      accountType: accountType,
      createdAt: DateTime.now(),
      target: target,
      maxLoss: maxLoss,
    );

    _accounts.add(account);
    await saveToJson();
    _updateListeners();
    return account;
  }

  /// Returns the account with the given ID for the active user, or null if not found.
  Account? getAccountById(int id) {
    try {
      return _accounts.firstWhere(
        (account) => account.id == id && account.userId == activeUser?.id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Updates the account with the given ID for the active user.
  Future<Account?> updateAccount({
    required int id,
    String? name,
    double? target,
    double? maxLoss,
  }) async {
    final accountIndex = _accounts.indexWhere(
      (account) => account.id == id && account.userId == activeUser?.id,
    );

    if (accountIndex == -1) return null;

    final oldAccount = _accounts[accountIndex];
    final updatedAccount = Account(
      id: oldAccount.id,
      userId: oldAccount.userId,
      name: name ?? oldAccount.name,
      balance: oldAccount.balance,
      startBalance: oldAccount.startBalance,
      accountType: oldAccount.accountType,
      createdAt: oldAccount.createdAt,
      target: target ?? oldAccount.target,
      maxLoss: maxLoss ?? oldAccount.maxLoss,
    );

    _accounts[accountIndex] = updatedAccount;
    await saveToJson();
    _updateListeners();
    return updatedAccount;
  }

  /// Updates the target and max loss for the account with the given ID.
  Future<Account?> updateAccountTarget(
    int id,
    double? target,
    double? maxLoss,
  ) async {
    final accountIndex = _accounts.indexWhere(
      (account) => account.id == id && account.userId == activeUser?.id,
    );
    if (accountIndex == -1) return null;

    // Create new account instance
    final updatedAccount = _accounts[accountIndex].copyWith(
      target: target,
      maxLoss: maxLoss,
    );

    // Update in-place (since _accounts is now mutable)
    _accounts[accountIndex] = updatedAccount;

    if (_activeAccount?.id == id) {
      _activeAccount = updatedAccount;
    }

    await saveToJson();
    _updateListeners();
    return updatedAccount;
  }

  /// Updates the balance for the account with the given ID.
  Future<Account?> updateAccountBalance(int id, double newBalance) async {
    if (newBalance < 0) {
      debugPrint('Cannot update account $id: Negative balance $newBalance');
      return null;
    }

    final accountIndex = _accounts.indexWhere(
      (account) => account.id == id && account.userId == activeUser?.id,
    );

    if (accountIndex == -1) {
      debugPrint('Account $id not found for user ${activeUser?.id}');
      return null;
    }

    debugPrint(
      'Updating account $id: Old Balance=${_accounts[accountIndex].balance}, New Balance=$newBalance',
    );
    _accounts[accountIndex] = _accounts[accountIndex].copyWith(
      balance: newBalance,
    );

    if (_activeAccount?.id == id) {
      _activeAccount = _accounts[accountIndex];
    }

    await saveToJson();
    _updateListeners();
    return _accounts[accountIndex];
  }

  /// Deletes the account with the given ID for the active user.
  Future<bool> deleteAccount(int id) async {
    final accountIndex = _accounts.indexWhere(
      (account) => account.id == id && account.userId == activeUser?.id,
    );

    if (accountIndex == -1) return false;

    if (_activeAccount?.id == id) {
      clearActiveAccount();
    }

    _accounts.removeAt(accountIndex);
    await saveToJson();
    _updateListeners();
    return true;
  }

  /// Loads accounts from persistent storage (accounts.json).
  Future<void> loadFromJson() async {
    final file = await _getAccountFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      _accounts.clear();

      for (var accountMap in jsonList) {
        final account = Account.fromMap(accountMap);
        _accounts.add(account);

        // Only consider account active if it belongs to current user
        if (account.isActive && activeUser?.id == account.userId) {
          _activeAccount = account;
        } else if (account.isActive) {
          // Deactivate accounts that don't belong to current user
          final index = _accounts.length - 1;
          _accounts[index] = _accounts[index].copyWith(isActive: false);
        }
      }

      if (_accounts.isNotEmpty) {
        _nextId =
            _accounts.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
      }
      _updateListeners();
    }
  }

  /// Saves the current list of accounts to persistent storage (accounts.json).
  Future<void> saveToJson() async {
    final file = await _getAccountFile();
    final accountList = _accounts.map((a) => a.toMap()).toList();
    final jsonContents = jsonEncode(accountList);
    await file.writeAsString(jsonContents);
  }
}
