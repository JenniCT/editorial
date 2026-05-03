
import 'package:flutter/material.dart';

/// TIPOS DE ACCIÓN PARA DEFINIR JERARQUÍA VISUAL
enum ActionType {
  primary,
  secondary,
  danger,
}

/// MODELO SIMPLE PARA BOTONES DEL ENCABEZADO
class HeaderButton {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final ActionType type;

  const HeaderButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.type = ActionType.secondary,
  });
}