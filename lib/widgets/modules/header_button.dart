import 'package:flutter/material.dart';

/// Tipos de acción para personalizar el color y estilo del botón.
enum ActionType { primary, secondary, danger }

/// Modelo simple que describe un botón del encabezado.
class HeaderButton {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final ActionType type;

  HeaderButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.type = ActionType.secondary,
  });
}
