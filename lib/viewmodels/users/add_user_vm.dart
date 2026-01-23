import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';

class AddUserVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AddUserVM();

  /// Transforma objetos UserModel a Mapas para la exportación a Excel
  List<Map<String, dynamic>> mapUsersToExport(List<UserModel> users) {
    return users.map((user) {
      return {
        'Nombre Completo': user.name,
        'Correo Electrónico': user.email,
        'Rol de Usuario': user.role.toString().split('.').last.toUpperCase(),
        'Fecha de Registro': DateFormat('dd/MM/yyyy').format(user.createAt),
        'Fecha de Expiración': user.expiresAt != null 
            ? DateFormat('dd/MM/yyyy').format(user.expiresAt!) 
            : 'No asignada',
        'Estado': user.status ? 'ACTIVO' : 'INACTIVO',
      };
    }).toList();
  }

  /// AGREGAR USUARIO Firebase Auth + Firestore
  Future<void> addUsuario(UserModel user) async {
    final errors = user.validate();
    if (errors.isNotEmpty) {
      throw Exception(errors.join(', '));
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      final uid = credential.user!.uid;

      final userData = user.toMap();
      userData['uid'] = uid; 
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      rethrow;
    }
  }

  /// OBTENER LOS USUARIOS
  Future<List<UserModel>> getUsuariosFirebase() async {
    try {
      final snapshot = await _firestore.collection('users').orderBy('name').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }


  /// AGREGAR O ACTUALIZAR USUARIO en la colección 'users'
  Future<void> importUsuario(UserModel user) async {
    try {
      // Si no tiene UID (como en una importación nueva), usamos el email como ID temporal 
      // o dejamos que Auth cree uno. Aquí usamos la lógica de tu addUsuario:
      await addUsuario(user); 
      debugPrint("Usuario ${user.email} importado con éxito");
    } catch (e) {
      debugPrint("Error importando a ${user.email}: $e");
      rethrow;
    }
  }
}