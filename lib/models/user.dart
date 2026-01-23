import 'package:cloud_firestore/cloud_firestore.dart';

enum Role { adm, staff, guest }

class UserModel {
  final String? uid;
  final String name;
  final String email;
  final String password; 
  final DateTime createAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final Role role;
  final bool status;
  bool selected = false;

  UserModel({
    this.uid, 
    required this.name,
    required this.email,
    required this.password,
    required this.createAt,
    this.updatedAt,
    this.expiresAt,
    required this.role,
    required this.status,
    this.selected = false,
  });

  //=========================== GETTERS REQUERIDOS POR LA VISTA ===========================//
  
  /// Retorna el nombre legible del rol
  String get roleName {
    switch (role) {
      case Role.adm:
        return 'Administrador';
      case Role.staff:
        return 'Personal';
      case Role.guest:
        return 'Usuario temporal';
    }
  }

  /// Retorna el icono representativo del rol
  String get roleIcon {
    switch (role) {
      case Role.adm:
        return '👑';
      case Role.staff:
        return '👨‍💼';
      case Role.guest:
        return '👤';
    }
  }

  //=========================== LÓGICA DE FIREBASE ===========================//

  factory UserModel.fromMap(Map<String, dynamic> data, {required String docId}) {
    final roleStr = (data['role'] as String?)?.trim().toLowerCase();
    final role = Role.values.firstWhere(
      (e) => e.toString().split('.').last == roleStr,
      orElse: () => Role.guest,
    );

    return UserModel(
      uid: (data['uid'] as String?)?.trim().isNotEmpty == true
          ? (data['uid'] as String)
          : docId,
      name: (data['name'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim().toLowerCase() ?? '',
      password: '', 
      createAt: (data['createAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      role: role,
      status: data['status'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid ?? '',
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'createAt': Timestamp.fromDate(createAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
      'role': role.toString().split('.').last,
      'status': status,
    };

    if (role == Role.guest && expiresAt != null) {
      map['expiresAt'] = Timestamp.fromDate(expiresAt!);
    }

    return map;
  }

  //=========================== VALIDACIÓN Y UTILIDADES ===========================//

  List<String> validate() {
    final errors = <String>[];
    if (name.trim().isEmpty) errors.add('Nombre es obligatorio');
    if (email.trim().isEmpty) errors.add('Email es obligatorio');
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isNotEmpty && !emailRegex.hasMatch(email.trim())) {
      errors.add('Formato de email inválido');
    }

    if (role == Role.guest && expiresAt == null) {
      errors.add('Usuario temporal requiere fecha de expiración');
    }
    return errors;
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? password,
    DateTime? createAt,
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}