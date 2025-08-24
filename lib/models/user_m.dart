enum Role { adm, lib, tem }

class UserModel {
  final String uid;
  final String email;
  final String password; // No debe guardarse en Firestore; lo dejamos vacío.
  final Role role;

  UserModel({
    required this.uid,
    required this.email,
    required this.password,
    required this.role,
  });

  // Usa docId como respaldo para uid y evita nulos con valores por defecto.
  factory UserModel.fromMap(
    Map<String, dynamic> data, {
    required String docId,
  }) {
    final roleStr = (data['role'] as String?)?.trim();
    final role = Role.values.firstWhere(
      (e) => e.toString().split('.').last == roleStr,
      orElse: () => Role.tem,
    );

    return UserModel(
      uid: (data['uid'] as String?)?.trim().isNotEmpty == true
          ? (data['uid'] as String)
          : docId,
      email: (data['email'] as String?) ?? '',
      password: (data['password'] as String?) ?? '', // normalmente no existe en Firestore
      role: role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'role': role.toString().split('.').last,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? password,
    Role? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

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

  @override
  String toString() =>
      'UserModel(uid: $uid, email: $email, role: ${role.toString().split('.').last})';
}