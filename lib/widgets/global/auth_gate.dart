import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../views/login/login_v.dart';
import '../../views/hm_layout.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Role _parseRole(String value) {
    switch (value) {
      case 'adm':   return Role.adm;
      case 'staff': return Role.staff;
      default:      return Role.guest;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Stream 1: estado de autenticación (persiste en Web automáticamente)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {

        // ── Esperando respuesta inicial de Firebase Auth ──
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ── Sin sesión → Login ────────────────────────────
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const Login();
        }

        final firebaseUser = authSnapshot.data!;

        // ── Con sesión → escuchar documento en Firestore ──
        return StreamBuilder<DocumentSnapshot>(
          // Stream 2: documento del usuario en tiempo real
          // Cualquier cambio en Firestore (nombre, rol, etc.)
          // llega aquí sin recargar la app.
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .snapshots(),
          builder: (context, userSnapshot) {

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Si el documento no existe o fue eliminado → logout
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // Cerramos sesión de Firebase para limpiar el estado
              FirebaseAuth.instance.signOut();
              return const Login();
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;
            final userModel = UserModel.fromMap(data, docId: firebaseUser.uid);
            final role = _parseRole(data['role'] as String? ?? '');

            return HomeLayout(user: userModel, role: role);
          },
        );
      },
    );
  }
}