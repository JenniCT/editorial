import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';

class AddUserVM {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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

  /// AGREGAR USUARIO Firebase Auth + Firestore (sin afectar sesión actual)
  Future<void> addUsuario(
    UserModel user,
    Map<String, Map<String, bool>> permisos,
  ) async {
    final errors = user.validate();
    if (errors.isNotEmpty) {
      throw Exception(errors.join(', '));
    }

    FirebaseApp? secondaryApp;

    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final credential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      final uid = credential.user!.uid;

      // Guarda datos del usuario
      final userData = user.toMap();
      userData['uid'] = uid;
      await _firestore.collection('users').doc(uid).set(userData);

      // Guarda permisos en subcolección (mismo formato que DetalleUsuarioVM)
      for (final mod in permisos.keys) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('permissions')
            .doc(mod)
            .set({
          'module': mod,
          'permissions': permisos[mod],
        });
      }
    } catch (e) {
      rethrow;
    } finally {
      await secondaryApp?.delete();
    }
  }

  /// OBTENER LOS USUARIOS
  Future<List<UserModel>> getUsuariosFirebase() async {
    try {
      final snapshot =
          await _firestore.collection('users').orderBy('name').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// IMPORTAR USUARIO
  Future<void> importUsuario(UserModel user) async {
    try {
      await addUsuario(user, {});
      debugPrint("Usuario ${user.email} importado con éxito");
    } catch (e) {
      debugPrint("Error importando a ${user.email}: $e");
      rethrow;
    }
  }
}