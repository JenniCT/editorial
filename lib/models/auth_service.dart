import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      debugPrint("Error en el login: $e");
      return null;
    }
  }


  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Si el correo está registrado, recibirás un enlace de recuperación.';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'Por favor ingresa un correo válido.';
      }
      return 'Si el correo está registrado, recibirás un enlace de recuperación.';
    } catch (_) {
      return 'Ocurrió un error al intentar enviar el correo. Intenta más tarde.';
    }
  }
}