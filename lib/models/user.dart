import 'package:cloud_firestore/cloud_firestore.dart';

enum Role { adm, staff, guest }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String password; 
  final DateTime createAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final Role role;
  final bool status;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.createAt,
    this.updatedAt,
    this.expiresAt,
    required this.role,
    required this.status,
  });

  /// Crear desde Firestore
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
      password: '', // Nunca viene de Firestore
      createAt: (data['createAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      expiresAt: role == Role.guest
          ? (data['expiresAt'] as Timestamp?)?.toDate()
          : null,
      role: role,
      status: data['status'] as bool? ?? true,
    );
  }

  /// MAPA PARA FIREBASE
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'createAt': Timestamp.fromDate(createAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
      'role': role.toString().split('.').last,
      'status': status,
    };

    // SOLO AGREGAR FECHA DE EXPIRACIÓN SOLO PARA GUEST
    if (role == Role.guest && expiresAt != null) {
      map['expiresAt'] = Timestamp.fromDate(expiresAt!);
    }

    return map;
  }

  /// CREAR COPIA DE DATOS
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

  /// NOMBRE DEL ROL
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

  /// ICONO DEL ROL
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

  /// VERIFICA QUE SI EL USUARIO ESTA ACTIVO Y NO EXPIRADO
  bool get isActive {
    if (!status) return false;
    if (role == Role.guest && expiresAt != null) {
      return DateTime.now().isBefore(expiresAt!);
    }
    return true;
  }

  ///DÍAS RESTANTES PARA EXPIRACIÓN
  int? get daysUntilExpiration {
    if (role != Role.guest || expiresAt == null) return null;
    final difference = expiresAt!.difference(DateTime.now());
    return difference.inDays;
  }

  /// VALIDAR DATOS DE USUARIO
  List<String> validate() {
    final errors = <String>[];

    if (uid.trim().isEmpty) {
      errors.add('UID es obligatorio');
    }

    if (name.trim().isEmpty) {
      errors.add('Nombre es obligatorio');
    } else if (name.trim().length < 2) {
      errors.add('Nombre debe tener al menos 2 caracteres');
    }

    if (email.trim().isEmpty) {
      errors.add('Email es obligatorio');
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email.trim())) {
        errors.add('Formato de email inválido');
      }
    }

    if (role == Role.guest && expiresAt == null) {
      errors.add('Usuario temporal requiere fecha de expiración');
    }

    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) {
      errors.add('Fecha de expiración debe ser futura');
    }

    return errors;
  }

  /// Convertir a string para debugging
  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, role: $role, status: $status)';
  }

  /// Comparar usuarios por UID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}