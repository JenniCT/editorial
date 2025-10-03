import 'package:flutter/material.dart';

// WIDGETS
import '../../widgets/login/logintext.dart';
import '../../widgets/global/background.dart';
import '../../widgets/login/password_reset.dart';
import '../../widgets/login/card_background.dart'; 

// VISTA-MODELO
import '../../viewmodels/login/login_vm.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final LoginVM vm = LoginVM();
  late AnimationController _controller;
  late Animation<double> _animation;

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
    vm.emailController.dispose();
    vm.passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(199, 217, 229, 1),
      body: Stack(
        children: [
          const BackgroundCircles(),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 250.0, top: 5.0, bottom: 20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 500,
                          height: 550,
                          child: CardBackground(
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment:  MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/unach.png', height: 50,),
                                      const SizedBox(width: 20,),
                                      Image.asset('assets/siresu.png', height: 50,)
                                    ],
                                  ),
                                  const SizedBox(height: 50),
                                  //TITULO
                                  const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
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
                                  //
                                  const SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () {
                                      showPasswordResetDialog(context, vm);
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

                                      vm.login(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromRGBO(26, 61, 99, 1),
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                                      shadowColor: const Color.fromRGBO(26, 61, 99, 0.4),
                                      elevation: 10,
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
                          ),
                        ),
                      ),
                      const SizedBox(width: 1),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
