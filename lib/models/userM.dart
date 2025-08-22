enum Role { adm, lib, tem }

class UserModel {
  final String email;
  final String password;
  final Role role;

  UserModel({
    required this.email,
    required this.password,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'],
      password: data['password'],
      role: Role.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => Role.tem,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'role': role.toString().split('.').last,
    };
  }

  UserModel copyWith({
    String? email,
    String? password,
    Role? role,
  }) {
    return UserModel(
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  /// Traduce el role a string legible
  String get roleName {
    switch (role) {
      case Role.adm:
        return 'Administrador';
      case Role.lib:
        return 'Bibliotecario';
      case Role.tem:
        return 'Usuario temporal';
    }
  }
}
