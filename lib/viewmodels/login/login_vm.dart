import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../views/hm_layout.dart';
import '../../models/auth_service.dart';
import '../../models/user.dart';
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
      await _showDialog(
        context,
        "Campos vacíos",
        "Por favor, completa todos los campos",
        Colors.orange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        if (!context.mounted) return;
        await _showDialog(
          context,
          "Error",
          "No se encontró el usuario",
          Colors.red,
          Icons.error,
        );
        return;
      }

      await user.reload();

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        if (!context.mounted) return;
        await _showDialog(
          context,
          "Error",
          "Usuario no registrado en la base de datos",
          Colors.red,
          Icons.error,
        );
        return;
      }

      final doc = query.docs.first;
      final data = doc.data();

      final rolStr = (data['role'] as String?) ?? '';
      final role = _parseRole(rolStr);
      final userModel = UserModel.fromMap(data, docId: doc.id);

      if (!context.mounted) return;
      await _showDialog(
        context,
        "Inicio de sesión exitoso",
        "Bienvenido a InkVentory",
        Colors.green,
        Icons.check_circle,
      );

      emailController.clear();
      passwordController.clear();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeLayout(user: userModel, role: role),
            ),
          );
        }
      });
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      if (e.code == 'user-not-found' ||
          e.code == "unknown-error" ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        await _showDialog(
          context,
          "Error",
          "Correo o contraseña incorrectos",
          Colors.red,
          Icons.error,
        );
      } else if (e.code == 'invalid-email') {
        await _showDialog(
          context,
          "Error",
          "Formato de correo inválido",
          Colors.orange,
          Icons.warning_amber_rounded,
        );
      } else if (e.code == 'user-disabled') {
        await _showDialog(
          context,
          "Error",
          "Esta cuenta ha sido deshabilitada",
          Colors.red,
          Icons.block,
        );
      } else {
        await _showDialog(
          context,
          "Error",
          "Error de autenticación: ${e.code}",
          Colors.red,
          Icons.error,
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      await _showDialog(
        context,
        "Error",
        "Error desconocido, revisa tu conexión",
        Colors.red,
        Icons.error,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Role _parseRole(String value) {
    switch (value) {
      case 'adm':
        return Role.adm;
      case 'staff':
        return Role.staff;
      case 'guest':
      default:
        return Role.guest;
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  Future<void> _showDialog(
    BuildContext context,
    String title,
    String message,
    Color color,
    IconData icon,
  ) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        color: color,
        icon: icon,
      ),
    );

    await Future.delayed(const Duration(seconds: 3));

    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}