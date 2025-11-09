//=========================== WIDGET DE CAMPO DE ENTRADA ===========================//
// ESTE COMPONENTE REPRESENTA UN ESPACIO DE EXPRESION SEGURA DONDE EL USUARIO INGRESA
// INFORMACION PERSONAL. SE DISENA PARA SER CLARO, HUMANO Y RESPONSIVO A SU ESTADO.

import 'package:flutter/material.dart';

class LoginInput extends StatefulWidget {

  // ETIQUETA QUE IDENTIFICA EL TIPO DE INFORMACION SOLICITADA
  final String label;

  // CONTROLADOR QUE ADMINISTRA EL TEXTO INGRESADO
  final TextEditingController controller;

  // DEFINE SI EL CAMPO ES OCULTO (CONTRASENA)
  final bool obscure;

  const LoginInput({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
  });

  @override
  State<LoginInput> createState() => _LoginInputState();
}

class _LoginInputState extends State<LoginInput> {

  // ESTADO QUE REFLEJA SI EL PUNTERO ESTA SOBRE EL CAMPO
  bool hovering = false;

  // ESTADO DE ENFOQUE QUE MUESTRA ATENCION Y ACCION DEL USUARIO
  bool focused = false;

  // CONTROLA SI SE MUESTRA LA CONTRASENA EN CAMPOS SENSIBLES
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {

    // DETERMINA SI EL CAMPO ES DE TIPO CONTRASENA
    final bool isPassword = widget.obscure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //=========================== ETIQUETA DEL CAMPO ===========================//
        // GUIA VISUAL QUE DA CONTEXTO Y APOYO EN LA INTERACCION
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B), // TONO FORMAL Y ESTRUCTURADO
          ),
        ),
        const SizedBox(height: 6),

        //=========================== MANEJO DE ENFOQUE Y HOVER ===========================//
        // CONTENEDOR QUE RESPONDE A ATENCION, PROXIMIDAD Y ENFOQUE DEL USUARIO
        FocusScope(
          child: Focus(
            onFocusChange: (f) => setState(() => focused = f),

            child: MouseRegion(
              onEnter: (_) => setState(() => hovering = true),
              onExit: (_) => setState(() => hovering = false),

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),

                // ALTURA ESTANDAR PARA COHERENCIA CON OTROS COMPONENTES
                height: 48,

                // ESPACIO INTERNO QUE PERMITE UNA ENTRADA CLARA Y HOLGADA
                padding: const EdgeInsets.symmetric(horizontal: 14),

                //=========================== DECORACION DEL CAMPO ===========================//
                // COLOR DE FONDO NEUTRO PARA UN AMBIENTE SUAVE Y CONTENIDO
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),

                  borderRadius: BorderRadius.circular(14), // SUAVIDAD HUMANA

                  // BORDE ADAPTATIVO QUE SEÑALA ESTADO DE ATENCION DEL USUARIO
                  border: Border.all(
                    width: 1.6,
                    color: focused
                        ? const Color(0xFF2563EB)    // COLOR AZUL PARA PRESENCIA ACTIVA
                        : hovering
                            ? const Color(0xFFAFC7E8) // TONO INTERMEDIO QUE INVITA A INTERACTUAR
                            : const Color(0xFFCBD5E1), // ESTADO BASE, NEUTRO Y SERENO
                  ),

                  // SOMBRA VARIABLE SEGUN ATENCION PARA REFORZAR PROFUNDIDAD EMOCIONAL
                  boxShadow: focused
                      ? [
                          BoxShadow(
                            color: const Color.fromRGBO(37, 99, 235, 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2), // LEVE ELEVACION
                          )
                        ]
                      : [
                          BoxShadow(
                            color: const Color.fromRGBO(0, 0, 0, 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),

                //=========================== CONTENIDO INTERNO ===========================//
                child: Row(
                  children: [

                    // ICONO REPRESENTATIVO DEL CAMPO (CORREO O CONTRASENA)
                    Icon(
                      isPassword ? Icons.lock_outline : Icons.email_outlined,
                      size: 20,
                      color: focused
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B), // TONO GRIS PROFESIONAL
                    ),

                    const SizedBox(width: 10),

                    //=========================== CAMPO DE TEXTO ===========================//
                    // AREA DONDE EL USUARIO ESCRIBE. SIMPLE, LIMPIA Y SIN RUIDO VISUAL
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        obscureText: isPassword && !showPassword,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none, // LIMPIEZA TOTAL DEL CAMPO
                        ),
                      ),
                    ),

                    //=========================== BOTON DE MOSTRAR CONTRASENA ===========================//
                    // APORTA CONTROL Y SEGURIDAD EN CAMPOS SENSIBLES
                    if (isPassword)
                      GestureDetector(
                        onTap: () => setState(() => showPassword = !showPassword),
                        child: Icon(
                          showPassword ? Icons.visibility : Icons.visibility_off,
                          size: 20,
                          color: focused
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
