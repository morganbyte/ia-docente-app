// lib/config/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Poppins',
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      letterSpacing: -0.5,
    ),
    titleMedium: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: -0.3,
    ),
    titleSmall: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      letterSpacing: -0.2,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textMedium,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textMedium,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: AppColors.textLight,
      height: 1.3,
    ),
    labelLarge: TextStyle( // Este estilo es comúnmente usado para texto de botones
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle( // Puedes añadir un estilo para texto de botones más pequeños
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.textDark),
    titleTextStyle: TextStyle(
      color: AppColors.textDark,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      letterSpacing: -0.3,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // ¡Aquí está el cambio clave para el texto de los botones!
      textStyle: const TextStyle( // Define el estilo de texto base para todos los ElevatedButton
        fontSize: 16,
        fontWeight: FontWeight.w600,
        // El fontFamily se hereda de 'Poppins' por el tema principal
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
  ),
);