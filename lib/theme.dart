import 'package:flutter/material.dart';

/// Central place for colours and the app theme.
/// The primary orange is reminiscent of typical delivery-app branding.
class AppColors {
  static const Color primary = Color(0xFFFF5A00); // orange
  static const Color primaryDark = Color(0xFFE04E00);
  static const Color background = Color(0xFFF6F6F6);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF7A7A7A);
  static const Color star = Color(0xFFFFB300);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
