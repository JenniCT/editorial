import 'package:cloud_firestore/cloud_firestore.dart';

enum Role { adm, staff, guest }

class UserModel {
  final String uid;           // ID del usuario
  final String name;          // Nombre
  final String email;         // Correo
  final String password;      // Contraseña
  final DateTime createAt;    // Fecha/hora de registro
  final DateTime? expiresAt;  // Solo si es "guest"
  final Role role;            // adm | staff | guest
  final bool status;          // Activo o no

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.createAt,
    this.expiresAt,
    required this.role,
    required this.status,
  });

  /// Crear desde Firestore
  factory UserModel.fromMap(
    Map<String, dynamic> data, {
    required String docId,
  }) {
    final roleStr = (data['role'] as String?)?.trim();
    final role = Role.values.firstWhere(
      (e) => e.toString().split('.').last == roleStr,
      orElse: () => Role.guest,
    );

    return UserModel(
      uid: (data['uid'] as String?)?.trim().isNotEmpty == true
          ? (data['uid'] as String)
          : docId,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      password: (data['password'] as String?) ?? '',
      createAt: (data['createAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: role == Role.guest
          ? (data['expiresAt'] as Timestamp?)?.toDate()
          : null,
      role: role,
      status: data['status'] as bool? ?? true,
    );
  }

  //CONVERTIR MAPA PARA FIRESTORE
  Map<String, dynamic> toMap() {
    final map = {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'createAt': Timestamp.fromDate(createAt), 
      'role': role.toString().split('.').last,
      'status': status,
    };

    if (role == Role.guest && expiresAt != null) {
      map['expiresAt'] = Timestamp.fromDate(expiresAt!);
    }

    return map;
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? password,
    DateTime? createAt,
    DateTime? expiresAt,
    Role? role,
    bool? status,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      createAt: createAt ?? this.createAt,
      expiresAt: role == Role.guest ? (expiresAt ?? this.expiresAt) : null,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  /// Nombre legible del rol
  String get roleName {
    switch (role) {
      case Role.adm:
        return 'Administrador';
      case Role.staff:
        return 'Estándar';
      case Role.guest:
        return 'Usuario temporal';
    }
  }

  @override
  String toString() =>
      'UserModel(uid: $uid, email: $email, role: ${role.toString().split('.').last}, status: $status)';
}