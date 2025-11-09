//=========================== BOTON PRINCIPAL DE ACCESO ===========================//
// ESTE BOTON REPRESENTA EL ACTO DE AVANZAR, TOMAR DECISION Y AFIRMAR IDENTIDAD.
// SU DISENO RESPONDE CON SUAVIDAD A HOVER Y PRESION PARA CREAR UNA EXPERIENCIA HUMANA.

import 'package:flutter/material.dart';

class LoginButton extends StatefulWidget {

  // TEXTO QUE IDENTIFICA LA ACCION A REALIZAR
  final String text;

  // ACCION EJECUTADA AL PRESIONAR EL BOTON
  final VoidCallback onTap;

  const LoginButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {

  // ESTADO QUE INDICA SI EL PUNTERO PASA SOBRE EL BOTON
  bool hovering = false;

  // ESTADO QUE INDICA PRESION DEL USUARIO SOBRE EL BOTON
  bool pressing = false;

  @override
  Widget build(BuildContext context) {

    //=========================== DETECCION DE INTERACCION ===========================//
    // MOUSE REGION Y LISTENER PERMITEN CAPTURAR HOVER Y PRESION PARA ANIMACIONES SUAVES
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),

      child: Listener(
        onPointerDown: (_) => setState(() => pressing = true),
        onPointerUp: (_) => setState(() => pressing = false),

        //=========================== ANIMACION DE ESCALA ===========================//
        // PEQUENA COMPRESION AL PRESIONAR QUE TRANSMITE NATURALEZA HUMANA Y SENSACION TACTIL
        child: AnimatedScale(
          scale: pressing ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),

          //=========================== CONTENEDOR DEL BOTON ===========================//
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 48,

            //=========================== ESTETICA DEL BOTON ===========================//
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),

              // DEGRADADO QUE REFORZA AUTORIDAD, ESTABILIDAD Y SOBRIEDAD INSTITUCIONAL
              gradient: LinearGradient(
                colors: hovering
                    ? const [
                        Color(0xFF274EAE), // TONO MAS CLARO PARA SENSACION DE PROXIMIDAD
                        Color(0xFF1E3A8A), // TONO CENTRAL FIRME
                      ]
                    : const [
                        Color(0xFF1E3A8A), // TONO BASE PROFUNDO
                        Color(0xFF162B65), // TONO MAS OSCURO PARA APORTAR PESO Y RAIZ
                      ],
              ),

              // SOMBRA QUE ELEVA EL BOTON Y MARCA SU IMPORTANCIA CENTRAL
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(30, 58, 138, 0.40),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),

            //=========================== SUPERFICIE INTERACTIVA ===========================//
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: widget.onTap,

              child: Center(
                child: Text(
                  widget.text,

                  //=========================== ESTILO DEL TEXTO ===========================//
                  // TIPOGRAFIA FIRME, CLARA Y LEGIBLE PARA EXPRESAR ACCION DECISIVA
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
