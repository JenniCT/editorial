//=========================== IMPORTACIONES ===========================//
import 'package:flutter/material.dart';

//=========================== CLASE DE COLORES DINÁMICOS SEGÚN MODO CLARO/OSCURO ===========================//

class DynamicColors {

  //=========================== COLORES PRINCIPALES ===========================//

  /// Azul UNACH — Primario institucional
  static Color primary(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF3B82F6) : const Color(0xFF025B9D);

  /// Hover primario
  static Color primaryHover(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF0369A1);

  /// Estado activo / seleccionado
  static Color primaryPressed(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF014B82);

  /// Luminoso (modo oscuro)
  static Color primaryLuminous(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF025B9D);


  //=========================== COLORES SECUNDARIOS (DORADO INSTITUCIONAL) ===========================//

  static Color secondary(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF8C741C) : const Color(0xFFAC8A1F);

  static Color secondaryHover(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF8C741C) : const Color(0xFFCBAE42);


  //=========================== COLORES DE FONDO Y SUPERFICIE ===========================//

  static Color background(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFb8cae0);

  static Color surface(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF28344e) : const Color(0xFFa4bad2);

  static Color border(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

  /// Sombra en modo claro debe ser RGBA(2, 91, 157, 0.08)
  static Color shadowOrElevation(bool isDarkMode) =>
      isDarkMode ? const Color(0x00000000) : const Color.fromRGBO(2, 91, 157, 0.08);


  //=========================== COLORES DE TEXTO ===========================//

  static Color textPrimary(bool isDarkMode) =>
      isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);

  static Color textSecondary(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  static Color textDisabled(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);


  //=========================== COLORES SEMÁNTICOS ===========================//

  static Color success(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);

  static Color warning(bool isDarkMode) =>
      const Color(0xFFFACC15);

  static Color error(bool isDarkMode) =>
      isDarkMode ? const Color(0xFFF87171) : const Color(0xFFEF4444);


  //=========================== BOTONES ===========================//

  static Color buttonPrimaryBackground(bool isDarkMode) =>
      primary(isDarkMode);

  static Color buttonPrimaryText(bool isDarkMode) =>
      const Color(0xFFFFFFFF);

  static Color buttonSecondaryBorder(bool isDarkMode) =>
      primary(isDarkMode);

  static Color buttonSecondaryBackground(bool isDarkMode) =>
      isDarkMode ? Colors.transparent : const Color(0xFFFFFFFF);

  static Color buttonSecondaryText(bool isDarkMode) =>
      primary(isDarkMode);

  static Color buttonDisabledBackground(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB);

  static Color buttonDisabledText(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);


  //=========================== CAMPOS DE FORMULARIO ===========================//

  static Color inputBackground(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  static Color inputBorder(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  static Color inputFocusedBorder(bool isDarkMode) =>
      primary(isDarkMode);


  //=========================== TARJETAS ===========================//

  static Color cardBackground(bool isDarkMode) =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  static Color cardBorder(bool isDarkMode) =>
      border(isDarkMode);

  static Color cardTitle(bool isDarkMode) =>
      textPrimary(isDarkMode);

  static Color cardIconActive(bool isDarkMode) =>
      primaryHover(isDarkMode);


  //=========================== DIVISORES ===========================//

  static Color divider(bool isDarkMode) =>
      border(isDarkMode);
}
