class User {
  final int? id;
  final String password;
  final String username;
  final String? createdAt;
  final bool isActive;

  User({
    this.id,
    required this.password,
    required this.username,
    this.createdAt,
    this.isActive = false, // default false
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'password': password,
      'username': username,
      'created_at': createdAt,
      'is_active': isActive, // new field
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      password: map['password'],
      username: map['username'],
      createdAt: map['created_at'],
      isActive: map['is_active'] ?? false,
    );
  }

  User copyWith({
    int? id,
    String? password,
    String? username,
    String? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      password: password ?? this.password,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
