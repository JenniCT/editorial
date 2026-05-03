import 'package:flutter/material.dart';

class ButtonStyles {
  /// PRIMARY BUTTON
  static ButtonStyle primary = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF1565C0),
  foregroundColor: Colors.white,
  minimumSize: const Size(140, 48),
  elevation: 2,
  shadowColor: const Color.fromRGBO(0, 0, 0, 0.8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  textStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  ),
);

  /// SECONDARY BUTTON
  static ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF1565C0),
    backgroundColor: Colors.white,
    minimumSize: const Size(140, 48),
    side: const BorderSide(
      color: Color(0xFF1565C0),
      width: 1.2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );  
  
  /// DANGER BUTTON
  static ButtonStyle danger = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFD32F2F),
    foregroundColor: Colors.white,
    minimumSize: const Size(140, 48),
    elevation: 2,
    shadowColor: const Color.fromRGBO(0, 0, 0, 0.08),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );

  /// ACTION ICON BUTTON
  static ButtonStyle icon(Color color) {
    return IconButton.styleFrom(
      foregroundColor: color,
      minimumSize: const Size(44, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}