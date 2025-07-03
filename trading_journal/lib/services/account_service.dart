import 'package:flutter/foundation.dart';
import 'package:trading_journal/services/trade_service.dart';
import '../models/account.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class AccountService extends ChangeNotifier {
  static final AccountService instance = AccountService._internal();

  final UserService _userService = UserService.instance;
  User? get activeUser => _userService.activeUser;

  final List<Account> _accounts = [];
  final ValueNotifier<List<Account>> accountsListenable =
      ValueNotifier([]);

  int _nextId = 1;
  Account? _activeAccount;
  Account? get activeAccount => _activeAccount;

  AccountService._internal() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_accounts.isEmpty) {
        _createTestAccount();
      }
    });
  }

  Future<void> setActiveAccount(int accountId) async {
    final account = getAccountById(accountId);
    if (account != null) {
      _activeAccount = account;
      notifyListeners();
      debugPrint('Active account set to: ${account.name}');
    } else {
      throw Exception('Account not found');
    }
  }

  void clearActiveAccount() {
    _activeAccount = null;
    notifyListeners();
    debugPrint('Active account cleared');
  }

  void _updateListeners() {
    accountsListenable.value = List.unmodifiable(_accounts);
    notifyListeners();
  }

  // Get accounts for active user
  List<Account> get accounts => accountsListenable.value;

  // In AccountService
  Future<void> _createTestAccount() async {
    if (activeUser == null) {
      debugPrint('No active user found. Cannot create test account.');
      return;
    }
    final double balance = 10000;

    final double target = balance * 1.08;
    final double maxLoss = balance * 0.9;

    final testAccount = Account(
      id: _nextId++,
      userId: activeUser!.id!,
      name: 'Testing Account',
      balance: balance,
      startBalance: balance,
      accountType: AccountType.demo,
      createdAt: DateTime.now(),
      target: target,
      maxLoss: maxLoss,
    );

    _accounts.add(testAccount);
    debugPrint('Created Test Account: ${testAccount.name}');

    // Update listeners before creating trades
    _updateListeners();

    // Set active account after listeners updated
    await setActiveAccount(testAccount.id);

    // Create trades after account is fully set up
    try {
      await TradeService.instance.createTestTradesForTestAccount(
        testAccount.id,
      );
      debugPrint('Successfully created test trades');
    } catch (e) {
      debugPrint('Error creating test trades: $e');
      // Consider removing the test account if trade creation fails
      // _accounts.remove(testAccount);
      // _updateListeners();
    }
  }

  Future<Account?> createAccount({
    required double balance,
    required AccountType accountType,
    required String name,
  }) async {
    if (activeUser == null) {
      debugPrint('No active user found. Cannot create account.');
      return null;
    }

    if (balance < 0) {
      debugPrint('Balance cannot be negative');
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
    _updateListeners();
    debugPrint(
      'Created account: ${account.name} (${account.accountType.displayName})',
    );
    return account;
  }

  // Get account by ID
  Account? getAccountById(int id) {
    try {
      return _accounts.firstWhere(
        (account) =>
            account.id == id && account.userId == activeUser?.id,
      );
    } catch (e) {
      return null;
    }
  }

  // Update account
  Future<Account?> updateAccount({
    required int id,
    String? name,

    double? target,
    double? maxLoss,
  }) async {
    final accountIndex = _accounts.indexWhere(
      (account) =>
          account.id == id && account.userId == activeUser?.id,
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
    _updateListeners();
    return updatedAccount;
  }

  Future<Account?> updateAccountTarget(
    int id,
    double? target,
    double? maxLoss,
  ) async {
    final accountIndex = _accounts.indexWhere(
      (account) =>
          account.id == id && account.userId == activeUser?.id,
    );
    if (accountIndex == -1) return null;
    final oldAccount = _accounts[accountIndex];
    final updatedAccount = oldAccount.copyWith(
      target: target,
      maxLoss: maxLoss,
    );
    _accounts[accountIndex] = updatedAccount;
    _updateListeners();
    return updatedAccount;
  }

  Future<Account?> updateAccountBalance(
    int id,
    double newBalance,
  ) async {
    if (newBalance < 0) {
      debugPrint('Balance cannot be negative');
    }

    final accountIndex = _accounts.indexWhere(
      (account) =>
          account.id == id && account.userId == activeUser?.id,
    );

    if (accountIndex == -1) {
      debugPrint('Account not found');
      return null;
    }

    // Update in accounts list
    _accounts[accountIndex] = _accounts[accountIndex].copyWith(
      balance: newBalance,
    );

    // Update active account if this is the active account
    if (_activeAccount?.id == id) {
      _activeAccount = _accounts[accountIndex];
    }

    _updateListeners();
    debugPrint(
      "[AccountService] Listeners notified. New balance: $newBalance",
    );

    return _accounts[accountIndex];
  }

  // Delete account
  Future<bool> deleteAccount(int id) async {
    final accountIndex = _accounts.indexWhere(
      (account) =>
          account.id == id && account.userId == activeUser?.id,
    );

    if (accountIndex == -1) return false;

    if (_activeAccount?.id == id) {
      clearActiveAccount();
    }

    _accounts.removeAt(accountIndex);
    _updateListeners();
    return true;
  }
}
