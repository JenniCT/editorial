import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

// AuthGate decide si mostrar Login o HomeLayout
import '../../../widgets/global/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://jfgzsnvzbeoajpvhotjk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmZ3pzbnZ6YmVvYWpwdmhvdGprIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyOTQzMzMsImV4cCI6MjA3Mzg3MDMzM30.F-azIB8-6KaWtO72dRi8TivuOfIAWzb9s1dxlhjOcRU',
  );

  runApp(const InkventoryApp());
}

class InkventoryApp extends StatelessWidget {
  const InkventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inkventory',
      debugShowCheckedModeBanner: false,

      // ── AuthGate como home ─────────────────────────────────
      // Ya no usamos initialRoute + routes para la navegación
      // principal. AuthGate escucha Firebase Auth y decide
      // si mostrar Login o HomeLayout, persistiendo la sesión
      // entre recargas automáticamente.
      home: const AuthGate(),

      // Rutas nombradas opcionales para navegación interna
      routes: {
        '/login': (context) => const AuthGate(),
      },

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
    );
  }
}