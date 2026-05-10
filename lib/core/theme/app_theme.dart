import 'package:flutter/material.dart';
import 'colors.dart';
import '../constants/ui_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        onPrimary: Colors.white,
        surface: AppColors.lightBackground,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainer: AppColors.lightSurfaceContainer,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: UiConstants.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusLg),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UiConstants.paddingMd,
          vertical: UiConstants.paddingSm,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        onPrimary: Colors.white,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainer: AppColors.darkSurfaceContainer,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: UiConstants.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusLg),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: UiConstants.paddingMd,
          vertical: UiConstants.paddingSm,
        ),
      ),
    );
  }
}
