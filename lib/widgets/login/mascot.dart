//=========================== WIDGET DE MASCOTA ANIMADA ===========================//
// ESTE WIDGET REPRESENTA UNA PRESENCIA SIMBOLICA QUE ACOMPANIA AL USUARIO DURANTE EL ACCESO
// SU MOVIMIENTO SUAVE GENERA UNA ATMOSFERA HUMANA, EMPATICA Y CERCANA

import 'package:flutter/material.dart';

class LoginMascot extends StatelessWidget {
  final AnimationController controller;

  const LoginMascot({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para que sea relativo al padre, no a toda la pantalla
    return LayoutBuilder(builder: (context, constraints) {
      final bool desktop = MediaQuery.of(context).size.width >= 1000;
      
      // Optimizamos: En móvil reducimos aún más el tamaño si la pantalla es pequeña
      final double screenWidth = MediaQuery.of(context).size.width;
      final double size = desktop ? 480 : (screenWidth < 400 ? 220 : 280);

      return RepaintBoundary( // <--- CLAVE PARA LA FLUIDEZ
        child: SizedBox(
          height: size + 40,
          width: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Sombra adaptable
              Positioned(
                bottom: 0,
                child: Container(
                  width: size * 0.55,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    color: const Color(0x33000000),
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // Animación optimizada
              AnimatedBuilder(
                animation: controller,
                builder: (_, child) {
                  final angle = (controller.value - 0.5) * 0.10;
                  return Transform.rotate(angle: angle, child: child);
                },
                child: Image.asset(
                  'assets/images/ocelote.webp',
                  height: size,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}