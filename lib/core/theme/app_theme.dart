//=========================== IMPORTACIONES ===========================//
import 'package:flutter/material.dart';
import 'app_text_styles.dart';
import 'dynamic_colors.dart';

//=========================== TEMA GLOBAL DE INKVENTORY ===========================//

/// Define el tema global de Inkventory para modo claro y oscuro.
/// Se basa en DynamicColors y AppTextStyles.
class AppTheme {
  /// Tema claro
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: DynamicColors.background(false),
    primaryColor: DynamicColors.primary(false),
    dividerColor: DynamicColors.divider(false),
    cardColor: DynamicColors.surface(false),
    useMaterial3: true,

    //=========================== TIPOGRAFÍA GLOBAL ===========================//
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1(color: DynamicColors.textPrimary(false)),
      displayMedium: AppTextStyles.h2(color: DynamicColors.textPrimary(false)),
      displaySmall: AppTextStyles.h3(color: DynamicColors.textPrimary(false)),
      bodyLarge: AppTextStyles.body(color: DynamicColors.textPrimary(false)),
      bodyMedium: AppTextStyles.secondary(color: DynamicColors.textSecondary(false)),
      labelLarge: AppTextStyles.label(color: DynamicColors.textPrimary(false)),
    ),

    //=========================== BOTONES ===========================//
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(DynamicColors.buttonPrimaryBackground(false)),
        foregroundColor: WidgetStateProperty.all(DynamicColors.buttonPrimaryText(false)),
        textStyle: WidgetStateProperty.all(AppTextStyles.label()),
        overlayColor: WidgetStateProperty.all(DynamicColors.primaryHover(false).withValues(alpha: 0.1)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all(
          BorderSide(color: DynamicColors.buttonSecondaryBorder(false)),
        ),
        foregroundColor: WidgetStateProperty.all(DynamicColors.buttonSecondaryText(false)),
        textStyle: WidgetStateProperty.all(AppTextStyles.label()),
        overlayColor: WidgetStateProperty.all(DynamicColors.primaryHover(false).withValues(alpha: 0.05)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),

    //=========================== CAMPOS DE TEXTO ===========================//
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DynamicColors.inputBackground(false),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DynamicColors.inputBorder(false)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DynamicColors.inputFocusedBorder(false), width: 2),
      ),
      hintStyle: AppTextStyles.secondary(color: DynamicColors.textSecondary(false)),
    ),
  );

  /// Tema oscuro
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: DynamicColors.background(true),
    primaryColor: DynamicColors.primary(true),
    dividerColor: DynamicColors.divider(true),
    cardColor: DynamicColors.surface(true),
    useMaterial3: true,

    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1(color: DynamicColors.textPrimary(true)),
      displayMedium: AppTextStyles.h2(color: DynamicColors.textPrimary(true)),
      displaySmall: AppTextStyles.h3(color: DynamicColors.textPrimary(true)),
      bodyLarge: AppTextStyles.body(color: DynamicColors.textPrimary(true)),
      bodyMedium: AppTextStyles.secondary(color: DynamicColors.textSecondary(true)),
      labelLarge: AppTextStyles.label(color: DynamicColors.textPrimary(true)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(DynamicColors.buttonPrimaryBackground(true)),
        foregroundColor: WidgetStateProperty.all(DynamicColors.buttonPrimaryText(true)),
        textStyle: WidgetStateProperty.all(AppTextStyles.label()),
        overlayColor: WidgetStateProperty.all(DynamicColors.primaryHover(true).withValues(alpha: 0.15)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all(
          BorderSide(color: DynamicColors.buttonSecondaryBorder(true)),
        ),
        foregroundColor: WidgetStateProperty.all(DynamicColors.buttonSecondaryText(true)),
        textStyle: WidgetStateProperty.all(AppTextStyles.label()),
        overlayColor: WidgetStateProperty.all(DynamicColors.primaryHover(true).withValues(alpha: 0.05)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DynamicColors.inputBackground(true),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DynamicColors.inputBorder(true)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: DynamicColors.inputFocusedBorder(true), width: 2),
      ),
      hintStyle: AppTextStyles.secondary(color: DynamicColors.textSecondary(true)),
    ),
  );
}
