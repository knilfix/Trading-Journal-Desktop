class User {
  final int? id;
  final String password;
  final String username;
  final String? createdAt;

  User({
    this.id,
    required this.password,
    required this.username,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'password': password,
      'full_name': username,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      password: map['password'],
      username: map['username'],
      createdAt: map['created_at'],
    );
  }
}
