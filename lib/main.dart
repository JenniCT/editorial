import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore/config/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/login/login_v.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await FirebaseFirestore.instance.clearPersistence();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  
  await Supabase.initialize(
    url: 'https://jfgzsnvzbeoajpvhotjk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmZ3pzbnZ6YmVvYWpwdmhvdGprIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyOTQzMzMsImV4cCI6MjA3Mzg3MDMzM30.F-azIB8-6KaWtO72dRi8TivuOfIAWzb9s1dxlhjOcRU',

  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {'/login': (context) => Login()},
    );
  }
}
