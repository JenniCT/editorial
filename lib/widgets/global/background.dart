import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final bool isDarkMode;
  final bool showEmptyStateIllustration;

  const Background({
    required this.isDarkMode,
    this.showEmptyStateIllustration = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Fondo plano según modo
    final Color mainBackground = isDarkMode ? Color(0xFF0E1726) :  Color(0xFF13203B);

    return Stack(
      children: [
        // Fondo principal plano de toda la pantalla
        Container(color: mainBackground),

        // Ilustración institucional discreta para estados vacíos
        if (showEmptyStateIllustration)
          Center(
            child: Icon(
              Icons.inventory_2_outlined,
              size: 120,
              color: Color.fromRGBO(2, 91, 157, 0.08),
            ),
          ),
      ],
    );
  }
}
