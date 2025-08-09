import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firestore/config/firebase_options.dart';
import 'views/login.dart';
import 'views/homelayout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      routes: {
        '/login': (context) =>  LoginView(),
        '/home': (context) => const HomeLayout(),
      },
    );
  }
}