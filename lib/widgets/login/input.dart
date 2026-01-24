//=========================== WIDGET DE CAMPO DE ENTRADA ===========================//
// ESTE COMPONENTE REPRESENTA UN ESPACIO DE EXPRESION SEGURA DONDE EL USUARIO INGRESA
// INFORMACION PERSONAL. SE DISENA PARA SER CLARO, HUMANO Y RESPONSIVO A SU ESTADO.

import 'package:flutter/material.dart';

class LoginInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  // Añadimos esta propiedad para que el AutofillGroup sepa qué campo es qué
  final Iterable<String>? autofillHints; 

  const LoginInput({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.autofillHints, // Lo integramos aquí
  });

  @override
  State<LoginInput> createState() => _LoginInputState();
}

class _LoginInputState extends State<LoginInput> {
  bool hovering = false;
  bool focused = false;
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    final bool isPassword = widget.obscure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        MouseRegion(
          onEnter: (_) => setState(() => hovering = true),
          onExit: (_) => setState(() => hovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                width: 1.6,
                color: focused
                    ? const Color(0xFF2563EB)
                    : hovering
                        ? const Color(0xFFAFC7E8)
                        : const Color(0xFFCBD5E1),
              ),
              boxShadow: focused
                  ? [
                      const BoxShadow(
                        color: Color.fromRGBO(37, 99, 235, 0.25),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ]
                  : [
                      const BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
            ),
            child: Row(
              children: [
                Icon(
                  isPassword ? Icons.lock_outline : Icons.email_outlined,
                  size: 20,
                  color: focused ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Focus( // Envolvemos con Focus para detectar el estado
                    onFocusChange: (f) => setState(() => focused = f),
                    child: TextField(
                      controller: widget.controller,
                      obscureText: isPassword && !showPassword,
                      autofillHints: widget.autofillHints,
                      textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
                      // Esta propiedad es genial para Web: quita el foco si haces clic fuera
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                if (isPassword)
                  GestureDetector(
                    onTap: () => setState(() => showPassword = !showPassword),
                    child: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                      color: focused ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}