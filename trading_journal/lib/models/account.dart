class Account {
  final int id;
  final int userId;
  final String name;
  final double balance;
  final double startBalance;
  final AccountType accountType; // Changed from String to AccountType
  final DateTime? createdAt;
  final double? target;
  final double? maxLoss;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
    required this.startBalance,
    required this.accountType,
    this.createdAt,
    this.target,
    this.maxLoss,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'balance': balance,
      'start_balance': startBalance,
      'account_type': accountType.name, // Store enum as string
      'created_at': createdAt
          ?.toIso8601String(), // Store as ISO string
      'target': target,
      'maxLoss': maxLoss,
    };
  }

  Account copyWith({
    int? id,
    int? userId,
    String? name,
    double? balance,
    double? startBalance,
    AccountType? accountType, // Updated type
    DateTime? createdAt,
    double? target,
    double? maxLoss,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      startBalance: startBalance ?? this.startBalance,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
      target: target ?? this.target,
      maxLoss: maxLoss ?? this.maxLoss,
    );
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      balance: map['balance'] as double,
      startBalance: map['start_balance'] as double,
      accountType: AccountType.values.firstWhere(
        (type) => type.name == map['account_type'],
        orElse: () => AccountType.demo,
      ),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      target: map['target'] != null ? map['target'] as double : null,
      maxLoss: map['maxLoss'] != null
          ? map['maxLoss'] as double
          : null,
    );
  }
}

enum AccountType {
  live,
  demo,
  backtesting;

  String get displayName {
    switch (this) {
      case AccountType.live:
        return 'Live Account';
      case AccountType.demo:
        return 'Demo Account';
      case AccountType.backtesting:
        return 'Backtesting Account';
    }
  }
}
