// lib/core/theme/app_text_styles.dart
// Tipografías para Inkventory (familia: Inter)
// Jerarquía definida por el usuario:
// H1: 24 px, peso 700, interlineado 32 px
// H2: 20 px, peso 600, interlineado 28 px
// H3: 18 px, peso 600, interlineado 26 px
// Body: 16 px, peso 400, interlineado 24 px
// Texto secundario: 14 px, peso 400, interlineado 20 px
// Etiquetas (botones/campos): 13 px, peso 500, interlineado 18 px

import 'package:flutter/material.dart';

class AppTextStyles {
  // Nota: se asume que la fuente "Inter" está registrada en pubspec.yaml.
  // Si no la agregaste, los dispositivos usarán la fuente por defecto.
  static const String _fontFamily = 'Inter';

  // Helper: convierte interlineado (px) en factor "height" relativo a fontSize.
  static double _height(double fontSize, double lineHeightPx) {
    return lineHeightPx / fontSize;
  }

  /// H1 - Encabezado principal
  static TextStyle h1({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24.0,
        fontWeight: FontWeight.w700, // 700
        height: _height(24.0, 32.0), // 32 px interlineado
        color: color,
      );

  /// H2 - Subtítulo
  static TextStyle h2({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20.0,
        fontWeight: FontWeight.w600, // 600
        height: _height(20.0, 28.0), // 28 px interlineado
        color: color,
      );

  /// H3 - Título de sección
  static TextStyle h3({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w600, // 600
        height: _height(18.0, 26.0), // 26 px interlineado
        color: color,
      );

  /// Body - Texto de cuerpo
  static TextStyle body({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w400, // 400
        height: _height(16.0, 24.0), // 24 px interlineado
        color: color,
      );

  /// Texto secundario / apoyo
  static TextStyle secondary({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14.0,
        fontWeight: FontWeight.w400, // 400
        height: _height(14.0, 20.0), // 20 px interlineado
        color: color,
      );

  /// Labels / botones / campos (más condensado)
  static TextStyle label({Color? color}) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 13.0,
        fontWeight: FontWeight.w500, // 500
        height: _height(13.0, 18.0), // 18 px interlineado
        color: color,
      );

  // Variantes rápidas para uso en temas (con color por defecto nulo)
  static TextStyle get headline1 => h1();
  static TextStyle get headline2 => h2();
  static TextStyle get headline3 => h3();
  static TextStyle get bodyText => body();
  static TextStyle get bodySecondary => secondary();
  static TextStyle get formLabel => label();
}
