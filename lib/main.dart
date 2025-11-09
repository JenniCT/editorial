//=========================== IMPORTACIONES PRINCIPALES ===========================//
import 'dart:ui'; // Requerido para PointerDeviceKind
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//=========================== CONFIGURACIÓN ===========================//
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

//=========================== VISTAS PRINCIPALES ===========================//
import 'views/login/login_v.dart';

//=========================== PUNTO DE ENTRADA ===========================//

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://jfgzsnvzbeoajpvhotjk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmZ3pzbnZ6YmVvYWpwdmhvdGprIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyOTQzMzMsImV4cCI6MjA3Mzg3MDMzM30.F-azIB8-6KaWtO72dRi8TivuOfIAWzb9s1dxlhjOcRU',
  );

  runApp(const InkventoryApp());
}

//=========================== APLICACIÓN PRINCIPAL ===========================//

class InkventoryApp extends StatelessWidget {
  const InkventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inkventory',
      debugShowCheckedModeBanner: false,


      //=========================== NAVEGACIÓN PRINCIPAL ===========================//
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        // futuras rutas:
        // '/dashboard': (context) => const DashboardView(),
        // '/inventario': (context) => const InventoryView(),
        // '/usuarios': (context) => const UsersView(),
      },

      //=========================== SOPORTE PARA WEB ===========================//
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
