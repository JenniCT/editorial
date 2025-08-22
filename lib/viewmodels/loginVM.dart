import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/auth_service.dart';
import '../models/userM.dart';
import 'package:editorial/views/homelayout.dart';
import '../widgets/dialog.dart';

class LoginVM with ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  bool isLoading = false;

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      _setLoading(true);

      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        _showErrorDialog(context, 'Error al iniciar sesión');
        return;
      }

      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _showErrorDialog(context, 'No se encontró información del usuario');
        return;
      }

      final DocumentSnapshot doc = query.docs.first;
      final String? roleString = doc.get('role');

      if (roleString == null) {
        _showErrorDialog(context, 'No se encontró el rol del usuario');
        return;
      }

      Role role;
      switch (roleString) {
        case 'adm':
          role = Role.adm;
          break;
        case 'lib':
          role = Role.lib;
          break;
        case 'tem':
        default:
          role = Role.tem;
      }

      final userModel = UserModel(
        email: email,
        password: password,
        role: role,
      );

      debugPrint('🎭 Rol del usuario: ${userModel.roleName}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeLayout(user: userModel),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error en login: $e');

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            _showErrorDialog(context, 'El correo no está registrado');
            break;
          case 'wrong-password':
            _showErrorDialog(context, 'La contraseña es incorrecta');
            break;
          case 'invalid-email':
            _showErrorDialog(context, 'El formato del correo no es válido');
            break;
          case 'network-request-failed':
            _showErrorDialog(context, 'Sin conexión a internet');
            break;
          case 'too-many-requests':
            _showErrorDialog(context, 'Demasiados intentos. Intenta más tarde');
            break;
          default:
            _showErrorDialog(context, 'Error: ${e.message}');
        }
      } else {
        _showErrorDialog(context, 'Error inesperado. Verifica tu conexión');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<String> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CustomDialog(
        title: '¡Ups!',
        message: message,
        color: Colors.redAccent,
        icon: Icons.error_outline,
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });

    _setLoading(false);
  }
}