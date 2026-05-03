import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/auth_service.dart';
import '../../widgets/global/dialog.dart';


class LoginVM with ChangeNotifier {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (!context.mounted) return;
      await _showDialog(context, "Campos vacíos",
          "Por favor, completa todos los campos", Colors.orange, Icons.warning_amber_rounded);
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user == null) {
        if (!context.mounted) return;
        await _showDialog(context, "Error", "No se encontró el usuario",
            Colors.red, Icons.error);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        if (!context.mounted) return;
        await _showDialog(context, "Error",
            "Usuario no registrado en la base de datos", Colors.red, Icons.error);
        return;
      }

      if (!context.mounted) return;
      await _showDialog(context, "Inicio de sesión exitoso",
          "Bienvenido a InkVentory", Colors.green, Icons.check_circle);

      // ── Sin Navigator aquí ────────────────────────────────
      // AuthGate detecta el cambio en authStateChanges()
      // y construye HomeLayout automáticamente.

      emailController.clear();
      passwordController.clear();

    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      if (e.code == 'user-not-found' ||
          e.code == 'unknown-error' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        await _showDialog(context, "Error", "Correo o contraseña incorrectos",
            Colors.red, Icons.error);
      } else if (e.code == 'invalid-email') {
        await _showDialog(context, "Error", "Formato de correo inválido",
            Colors.orange, Icons.warning_amber_rounded);
      } else if (e.code == 'user-disabled') {
        await _showDialog(context, "Error", "Esta cuenta ha sido deshabilitada",
            Colors.red, Icons.block);
      } else {
        await _showDialog(context, "Error",
            "Error de autenticación: ${e.code}", Colors.red, Icons.error);
      }
    } catch (_) {
      if (!context.mounted) return;
      await _showDialog(context, "Error",
          "Error desconocido, revisa tu conexión", Colors.red, Icons.error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  Future<void> _showDialog(BuildContext context, String title, String message,
      Color color, IconData icon) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) =>
          CustomToast(title: title, message: message, color: color, icon: icon),
    );
    await Future.delayed(const Duration(milliseconds: 1200));
    if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
  }
}