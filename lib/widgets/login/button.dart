import 'package:flutter/material.dart';

class LoginButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading; // Nueva propiedad: Indica si está procesando el login

  const LoginButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false, // Por defecto no carga
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool hovering = false;
  bool pressing = false;

  @override
  Widget build(BuildContext context) {
    // 1. RepaintBoundary: Evita que la animación del botón ralentice el resto de la UI.
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => hovering = true),
        onExit: (_) => setState(() => hovering = false),
        child: Listener(
          onPointerDown: (_) => setState(() => pressing = true),
          onPointerUp: (_) => setState(() => pressing = false),
          child: AnimatedScale(
            scale: (pressing || widget.isLoading) ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: hovering
                      ? const [Color(0xFF274EAE), Color(0xFF1E3A8A)]
                      : const [Color(0xFF1E3A8A), Color(0xFF162B65)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(30, 58, 138, 0.40),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                // Deshabilitar el tap si está cargando para evitar múltiples peticiones
                onTap: widget.isLoading ? null : widget.onTap,
                child: Center(
                  // 2. Switcher de contenido: Muestra el texto o un spinner
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.text,
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
      ),
    );
  }
}