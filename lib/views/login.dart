import 'package:editorial/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'homelayout.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

final AuthService _authService = AuthService();

void _handleLogin(BuildContext context) async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  final user = await _authService.login(email, password);

  if(user != null){
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const HomeLayout()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Credenciales Incorrectas")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ()  => _handleLogin(context),


                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.lightBlue[50],
    );
  }
}
