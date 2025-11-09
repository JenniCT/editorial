//=========================== WIDGET DE MASCOTA ANIMADA ===========================//
// ESTE WIDGET REPRESENTA UNA PRESENCIA SIMBOLICA QUE ACOMPANIA AL USUARIO DURANTE EL ACCESO
// SU MOVIMIENTO SUAVE GENERA UNA ATMOSFERA HUMANA, EMPATICA Y CERCANA

import 'package:flutter/material.dart';

class LoginMascot extends StatelessWidget {

  // CONTROLADOR QUE GOBIERNA EL MOVIMIENTO OSCILANTE DE LA MASCOTA
  final AnimationController controller;

  const LoginMascot({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {

    //=========================== DETECCION DE ENTORNO ===========================//
    // DETERMINA SI LA INTERFAZ ESTA EN ESCRITORIO PARA AJUSTAR ESCALAS Y JERARQUIAS VISUALES
    final bool desktop = MediaQuery.of(context).size.width >= 1000;

    // TAMANO ADAPTATIVO PARA PRESERVAR PRESENCIA Y CLARIDAD SEGUN DISPOSITIVO
    final double size = desktop ? 480 : 300;

    return SizedBox(
      height: size + 40,   // ESPACIO EXTRA PARA LA SOMBRA SUAVE
      width: size,

      //=========================== ESTRUCTURA DE CAPAS ===========================//
      // STACK PERMITE SUPERPONER SOMBRA Y MASCOTA PARA UNA COMPOSICION ARMONICA
      child: Stack(
        alignment: Alignment.center,
        children: [

          //=========================== SOMBRA DIFUSA ===========================//
          // REFORZAMOS LA SENSACION DE PRESENCIA Y ESTABILIDAD BAJO LA MASCOTA
          // COLOR NEGRO TRANSLUCIDO PARA UNA PROYECCION DISCRETA Y ELEGANTE
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.55,
              height: size * 0.12,
              decoration: BoxDecoration(
                color: const Color(0x33000000), 
                borderRadius: BorderRadius.circular(200),

                // SOMBRA ADICIONAL PARA DAR PROFUNDIDAD A LA BASE
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

          //=========================== ANIMACION PRINCIPAL DE LA MASCOTA ===========================//
          // USAMOS ANIMATEDBUILDER PARA SINCRONIZAR ANGULO Y MOVIMIENTO CON EL CONTROLADOR
          // EL BALANCEO SUAVE TRANSMITE CALMA, ACOGIDA Y VITALIDAD
          AnimatedBuilder(
            animation: controller,
            builder: (_, child) {

              // CALCULO DEL ANGULO DE OSCILACION
              // SE BASA EN UN DESPLAZAMIENTO PEQUENO PARA MANTENER NATURALIDAD
              final angle = (controller.value - 0.5) * 0.10;

              // TRANSFORMACION QUE GIRA LA IMAGEN PARA SIMULAR MOVIMIENTO VIVO
              return Transform.rotate(angle: angle, child: child);
            },

            //=========================== RECURSO VISUAL DE LA MASCOTA ===========================//
            // IMAGEN INSTITUCIONAL DEL OCELOTE, REPRESENTANDO IDENTIDAD Y PROTECCION
            child: Image.asset(
              'assets/images/ocelote.png',
              height: size,
              fit: BoxFit.contain, 
            ),
          ),
        ],
      ),
    );
  }
}
