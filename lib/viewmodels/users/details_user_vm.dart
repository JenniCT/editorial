import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';

class DetalleUsuarioVM {
  final UserModel usuario;

  DetalleUsuarioVM({required this.usuario});

  /// Formato de fecha
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Acción de editar usuario (abre un dialog, etc.)
  void editarUsuario(BuildContext context, Function(UserModel) onUpdate) {
    // Aquí abrirías tu diálogo de edición
    // Ejemplo placeholder:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Función de editar usuario")),
    );

    // Simulación de actualización:
    final updatedUser = usuario.copyWith(name: "${usuario.name} (editado)");
    onUpdate(updatedUser);
  }
}
