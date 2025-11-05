import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleUsuarioVM {
  final UserModel usuario;

  DetalleUsuarioVM({required this.usuario});

  /// Formato de fecha
  String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  /// Acción de editar usuario (placeholder)
  void editarUsuario(BuildContext context, Function(UserModel) onUpdate) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Función de editar usuario")),
    );

    final updatedUser = usuario.copyWith(name: "${usuario.name} (editado)");
    onUpdate(updatedUser);
  }

  /// Validación avanzada de permisos
  Map<String, String?> validarPermisosAvanzado(Map<String, Map<String, bool>> permisos) {
    Map<String, String?> errores = {};

    permisos.forEach((mod, acciones) {

      if (usuario.role == Role.guest && acciones['Eliminar'] == true) {
        errores[mod] = "Usuario temporal no puede eliminar";
      }

      final accionesValidas = ['Ver', 'Editar', 'Eliminar'];
      if (!acciones.keys.toSet().containsAll(accionesValidas)) {
        errores[mod] = "Acciones inválidas";
      }
    });

    return errores;
  }

  /// Guardar permisos en Firestore (crea la colección si no existe)
  Future<void> guardarPermisos(Map<String, Map<String, bool>> permisos) async {
    for (var mod in permisos.keys) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .collection('permissions')
          .doc(mod);
      await docRef.set({
        'module': mod,
        'permissions': permisos[mod],
      });
    }
  }
}
