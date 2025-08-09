import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? errorMessage;

  Future<User?> login(String email, String password) async {
    final user = await _authService.login(email, password);
    if (user == null) {
      errorMessage = 'Credenciales incorrectas. Por favor, inténtalo de nuevo.';
      notifyListeners();
    } 
    return user;
  }
  Future<String> sendPasswordResetEmail(String email) async{
    return await _authService.sendPasswordResetEmail(email);
  }
}