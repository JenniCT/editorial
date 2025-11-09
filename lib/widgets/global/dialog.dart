//=========================== IMPORTACIONES PRINCIPALES ===========================//
// IMPORTACION DE FLUTTER PARA CONSTRUCCION DE UI Y ANIMACIONES
import 'package:flutter/material.dart';

//=========================== WIDGET TOAST PERSONALIZADO ===========================//
// WIDGET RESPONSABLE DE MOSTRAR MENSAJES EMOCIONALMENTE CLAROS Y VISUALMENTE ATRACTIVOS
class CustomToast extends StatefulWidget {
  final String title; // TITULO DEL TOAST, DESTACA EL CONTEXTO DEL MENSAJE
  final String message; // MENSAJE DESCRIPTIVO DEL TOAST
  final Color color; // COLOR DEL ICONO PARA REFLEJAR EL TIPO DE MENSAJE (EXITO, ERROR, ADVERTENCIA)
  final IconData icon; // ICONO QUE REPRESENTA VISUALMENTE EL ESTADO
  final double durationSeconds; // DURACION DEL TOAST EN SEGUNDOS

  const CustomToast({
    super.key,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    this.durationSeconds = 4.0,
  });

  @override
  State<CustomToast> createState() => _CustomToastState();
}

//=========================== ESTADO DEL WIDGET ===========================//
// MANEJA ANIMACIONES DE ENTRADA, SALIDA Y OPACIDAD DEL TOAST
class _CustomToastState extends State<CustomToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // CONTROLADOR DE ANIMACION
  late Animation<Offset> _slideAnimation; // ANIMACION DE DESPLAZAMIENTO
  late Animation<double> _fadeAnimation; // ANIMACION DE OPACIDAD

  @override
  void initState() {
    super.initState();

    // INICIALIZACION DEL CONTROLADOR DE ANIMACION
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // DURACION SUAVE PARA ENTRADA
    );

    //=========================== ANIMACION DE DESLIZAMIENTO ===========================//
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // EMPIEZA FUERA DE PANTALLA A LA DERECHA
      end: Offset.zero, // TERMINA EN POSICION CENTRAL
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut), // CURVA NATURAL
    );

    //=========================== ANIMACION DE OPACIDAD ===========================//
    _fadeAnimation = Tween<double>(
      begin: 0.0, // TRANSPARENTE AL INICIO
      end: 1.0,   // COMPLETAMENTE VISIBLE
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn), // APARECIDA SUAVE
    );

    _controller.forward(); // INICIA LA ANIMACION AL CREAR EL WIDGET

    //=========================== CIERRE AUTOMATICO ===========================//
    Future.delayed(Duration(milliseconds: (widget.durationSeconds * 1000).toInt()), () {
      if (mounted) {
        _controller.reverse().then((value) => Navigator.of(context).pop()); // DESAPARECE EL TOAST
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // LIMPIEZA DE RECURSOS DE ANIMACION
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight, // POSICION DEL TOAST EN PANTALLA
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SlideTransition(
          position: _slideAnimation, // ANIMACION DE DESPLAZAMIENTO
          child: FadeTransition(
            opacity: _fadeAnimation, // ANIMACION DE OPACIDAD
            child: Material(
              color: Colors.white, // FONDO DEL TOAST
              elevation: 4, // SOMBRA PARA DESTACAR SOBRE EL FONDO
              borderRadius: BorderRadius.circular(12), // BORDES SUAVES
              shadowColor: const Color.fromRGBO(0, 0, 0, 0.15), // SOMBRA LEVE
              child: Container(
                constraints: const BoxConstraints(maxWidth: 350), // MAXIMO ANCHO
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ICONO DEL TOAST, COLOR REFLEJA TIPO DE MENSAJE
                    Icon(widget.icon, color: widget.color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITULO DESTACADO DEL MENSAJE
                          Text(
                            widget.title,
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 2),
                          // MENSAJE DETALLADO
                          Text(
                            widget.message,
                            style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87),
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
    );
  }
}

//=========================== FUNCION DE UTILIDAD ===========================//
// FUNCION RAPIDA PARA MOSTRAR EL TOAST, FACILITA USO DESDE CUALQUIER PANTALLA
void showCustomToast(BuildContext context,
    {required String title,
    required String message,
    required Color color,
    required IconData icon,
    double durationSeconds = 4.0}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false, // HACE QUE LA RUTA SEA TRANSPARENTE
      pageBuilder: (_, _, _) => CustomToast(
        title: title,
        message: message,
        color: color,
        icon: icon,
        durationSeconds: durationSeconds,
      ),
    ),
  );
}
