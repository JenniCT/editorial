import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo azul nocturno uniforme
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF011E33),
          ),
        ),

        // Capa muy sutil de ruido
        Opacity(
          opacity: 0.015, // 1.5 %
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/noise.png'),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),

        // Halo radial en la parte izquierda (zona ilustrativa)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.82, -0.82), // 18 % desde la esquina superior izquierda
                  radius: 1.2,
                  colors: [
                    Color.fromRGBO(1, 30, 51, 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Huellas como textura (10–12 % y escala 40–90 px)
        _buildFootprint(80, 120, 90, 0.12),
        _buildFootprint(260, 140, 40, 0.10),
        _buildFootprint(420, 110, 70, 0.12),
        _buildFootprint(600, 150, 50, 0.10),
        _buildFootprint(780, 180, 90, 0.12),

        // Sello de garra en esquina inferior derecha, dorado 12 %
        Positioned(
          bottom: 40,
          right: 40,
          child: Opacity(
            opacity: 0.12,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFFAC8A1F),
                BlendMode.srcATop,
              ),
              child: Image.asset(
                'assets/images/garra.png',
                height: 130,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget utilitario para repetir huellas pequeñas
  Widget _buildFootprint(double top, double left, double size, double opacity) {
    return Positioned(
      top: top,
      left: left,
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          'assets/images/garra.png', // usa huella pequeña
          height: size,
        ),
      ),
    );
  }
}
