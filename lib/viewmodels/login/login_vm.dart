//=========================== IMPORTACIONES PRINCIPALES ===========================//
// SE IMPORTAN PAQUETES DE FIREBASE PARA AUTENTICACION Y BASE DE DATOS
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORTACIONES DE FLUTTER PARA UI Y NAVEGACION
import 'package:flutter/material.dart';

// IMPORTACIONES DE VISTAS, MODELOS Y WIDGETS INTERNOS
import '../../views/hm_layout.dart';
import '../../models/auth_service.dart';
import '../../models/user.dart';
import '../../widgets/global/dialog.dart';

//=========================== VISTA-MODELO LOGIN ===========================//
// CLASE QUE MANEJA LA LOGICA DE AUTENTICACION Y ESTADO DE LOGIN
class LoginVM with ChangeNotifier {
  // SERVICIO DE AUTENTICACION PERSONALIZADO
  final AuthService _authService = AuthService();

  // CONTROLADORES DE TEXTO PARA INPUTS DE CORREO Y CONTRASEÑA
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // INDICADOR DE CARGA PARA MOSTRAR SPINNER O BLOQUEO DE INTERFAZ
  bool isLoading = false;

  //=========================== FUNCION LOGIN ===========================//
  // LOGICA PRINCIPAL PARA INICIAR SESION, CON VALIDACIONES Y MENSAJES EMOCIONALES
  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // VALIDACION DE CAMPOS VACIOS
    if (email.isEmpty || password.isEmpty) {
      if (!context.mounted) return;
      await _showDialog(
        context,
        "Campos vacíos",
        "Por favor, completa todos los campos",
        Colors.orange, // COLOR NARANJA PARA ADVERTENCIA
        Icons.warning_amber_rounded,
      );
      return;
    }

    try {
      // INICIO DE CARGA Y NOTIFICACION A LA UI
      isLoading = true;
      notifyListeners();

      // AUTENTICACION CON FIREBASE
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      // VALIDACION DE USUARIO NULO
      if (user == null) {
        if (!context.mounted) return;
        await _showDialog(
          context,
          "Error",
          "No se encontró el usuario",
          Colors.red, // COLOR ROJO PARA ERROR
          Icons.error,
        );
        return;
      }

      await user.reload();

      // CONSULTA DE INFORMACION DEL USUARIO EN FIRESTORE
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // VALIDACION DE USUARIO REGISTRADO
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

      // OBTENCION DE DATOS DEL DOCUMENTO
      final doc = query.docs.first;
      final data = doc.data();

      // PARSEO DEL ROL DEL USUARIO
      final rolStr = (data['role'] as String?) ?? '';
      final role = _parseRole(rolStr);

      // CREACION DE MODELO DE USUARIO
      final userModel = UserModel.fromMap(data, docId: doc.id);

      // MOSTRAR DIALOGO DE BIENVENIDA
      if (!context.mounted) return;
      await _showDialog(
        context,
        "Inicio de sesión exitoso",
        "Bienvenido a InkVentory",
        Colors.green, // COLOR VERDE PARA EXITO
        Icons.check_circle,
      );

      // LIMPIEZA DE CAMPOS DE TEXTO
      emailController.clear();
      passwordController.clear();

      // NAVEGACION A HOME LAYOUT CON RETARDO PARA MEJOR EXPERIENCIA
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
    } 
    //=========================== MANEJO DE ERRORES DE FIREBASE ===========================//
    on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      // ERRORES COMUNES DE AUTENTICACION
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
    } 
    //=========================== ERRORES GENERALES ===========================//
    catch (_) {
      if (!context.mounted) return;
      await _showDialog(
        context,
        "Error",
        "Error desconocido, revisa tu conexión",
        Colors.red,
        Icons.error,
      );
    } 
    // FINALIZA CARGA
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //=========================== PARSEO DE ROL ===========================//
  // CONVIERTE UN STRING DE ROL A ENUM INTERNAMENTE
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

  //=========================== FUNCION RECUPERAR CONTRASEÑA ===========================//
  Future<String> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  //=========================== DIALOGOS PERSONALIZADOS ===========================//
  // MUESTRA UN DIALOGO CON ICONO, COLOR Y TEXTO, PARA MEJOR NARRATIVA VISUAL
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

    // MANTENER EL DIALOGO VISIBLE 3 SEGUNDOS
    await Future.delayed(const Duration(seconds: 3));

    // CERRAR AUTOMATICAMENTE SI TODAVIA SE PUEDE
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
