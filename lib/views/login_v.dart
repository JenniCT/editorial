import 'dart:ui';
import 'package:flutter/material.dart';

//WIDGETS
import '../widgets/logintext.dart';
import '../widgets/background.dart';

//VISTA-MODELO
import '../viewmodels/login_vm.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginVM viewModel = LoginVM();
  final LoginVM vm = LoginVM();
  late AnimationController _controller;
  late Animation<double> _animation;

  void _showPasswordResetDialog(BuildContext context, LoginVM viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final TextEditingController resetController = TextEditingController();

        return AlertDialog(
          title: const Text('Recuperar Contraseña'),
          content: TextField(
            controller: resetController,
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(dialogContext);

                final message = await viewModel.sendPasswordResetEmail(
                  resetController.text.trim(),
                );

                if (navigator.canPop()) navigator.pop();

                messenger.showSnackBar(
                  SnackBar(content: Text(message)),
                );
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 217, 229, 1),
      body: Stack(
        children: [
          const BackgroundCircles(), 
          // FORMULARIO
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 250.0, top: 5.0, bottom: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TÍTULO
                      Text(
                        'Bienvenido a InkVentory',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w300,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1
                            ..color = const Color.fromRGBO(0, 0, 0, 0.8),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // FORMULARIO
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 500,
                              height: 550,
                              child: Stack(
                                children: [
                                  // FONDO
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(255, 255, 255, 0.1),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(
                                            color: const Color.fromRGBO(255, 255, 255, 0.3),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromRGBO(0, 0, 0, 0.2),
                                              blurRadius: 30,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // CONTENIDO
                                  Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/unach.png', height: 50),
                                            const SizedBox(width: 16),
                                            Image.asset('assets/siresu.png', height: 50),
                                          ],
                                        ),
                                        const SizedBox(height: 70),
                                        const Text(
                                          'Iniciar sesión',
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        CustomTextField(
                                          controller: vm.emailController,
                                          label: 'Correo Electrónico',
                                          icon: Icons.email,
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        const SizedBox(height: 12),
                                        CustomTextField(
                                          controller: vm.passwordController,
                                          label: 'Contraseña',
                                          icon: Icons.lock,
                                          isPassword: true,
                                          keyboardType: TextInputType.visiblePassword,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'La contraseña es obligatoria';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        TextButton(
                                          onPressed: () {
                                            _showPasswordResetDialog(context, vm);
                                          },
                                          child: const Text(
                                            '¿Olvidaste tu contraseña?',
                                            style: TextStyle(
                                              color: Color.fromRGBO(0, 0, 0, 1),
                                              fontSize: 18,
                                              decoration: TextDecoration.none,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            final email = vm.emailController.text.trim();
                                            final password = vm.passwordController.text.trim();

                                            if (email.isEmpty || password.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Completa todos los campos')),
                                              );
                                              return;
                                            }

                                            vm.login(
                                              context,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromRGBO(26, 61, 99, 1),
                                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Iniciar sesión',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 1),

                          // MASCOTA
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _animation.value,
                                child: child,
                              );
                            },
                            child: Image.asset('assets/ocelote.png', height: 500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}