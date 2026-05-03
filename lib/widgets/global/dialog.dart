//=========================== IMPORTACIONES PRINCIPALES ===========================//
// IMPORTACION DE FLUTTER PARA UI, ANIMACIONES Y OVERLAY
import 'package:flutter/material.dart';

//=========================== TOAST PERSONALIZADO CON OVERLAY ===========================//

class CustomToast extends StatefulWidget {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final double durationSeconds;

  const CustomToast({
    super.key,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    this.durationSeconds = 1.2, // MENOR TIEMPO PARA MAYOR FLUIDEZ
  });

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    //=========================== CONTROLADOR DE ANIMACION ===========================//
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    //=========================== ANIMACION DE ENTRADA ===========================//
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.25, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    //=========================== ANIMACION DE OPACIDAD ===========================//
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.white,
                elevation: 8,
                borderRadius: BorderRadius.circular(14),
                shadowColor: const Color.fromRGBO(0, 0, 0, 0.12),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 360,
                    minWidth: 280,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.color,
                        size: 26,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              widget.message,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

//=========================== FUNCION GLOBAL PARA MOSTRAR TOAST ===========================//
// ESTA FUNCION USA OVERLAYENTRY
// NO CREA RUTAS NUEVAS
// NO USA NAVIGATOR.PUSH()
// ES MAS RAPIDA Y MAS SEGURA

void showCustomToast(
  BuildContext context, {
  required String title,
  required String message,
  required Color color,
  required IconData icon,
  double durationSeconds = 1.2,
}) {
  final overlay = Overlay.of(context);

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => CustomToast(
      title: title,
      message: message,
      color: color,
      icon: icon,
      durationSeconds: durationSeconds,
    ),
  );

  overlay.insert(overlayEntry);

  //=========================== REMOCION AUTOMATICA ===========================//
  Future.delayed(
    Duration(
      milliseconds: (durationSeconds * 1000).toInt(),
    ),
    () {
      overlayEntry.remove();
    },
  );
}