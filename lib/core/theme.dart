import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const primary = Color(0xFF3B82F6);
  static const primaryLight = Color(0xFF60A5FA);

  // Background
  static const bgDeep = Color(0xFF111111);
  static const bgMid = Color(0xFF181818);
  static const bgSurface = Color(0xFF1E1E1E);
  static const bgCard = Color(0xFF1A1A1A);

  // Accents
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFAAAAAA);
  static const textMuted = Color(0xFF666666);

  // Borders
  static const borderLight = Color(0xFF2A2A2A);
  static const borderGlow = Color(0xFF3B82F6);
}

class AppTypography {
  AppTypography._();

  static const _family = 'Inter';

  static TextStyle displayLarge([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 26, fontWeight: FontWeight.w700,
    letterSpacing: -0.5, color: AppColors.textPrimary, height: 1.15,
  );

  static TextStyle heading1([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.25,
  );

  static TextStyle heading2([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.3,
  );

  static TextStyle body([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );

  static TextStyle bodySmall([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textMuted, height: 1.4,
  );

  static TextStyle caption([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textMuted, letterSpacing: 0.4,
  );

  static TextStyle label([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.3,
  );

  static TextStyle buttonText([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w600,
    color: Colors.white, letterSpacing: 0.2,
  );

  static TextStyle price([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.success, letterSpacing: -0.3,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.bgSurface,
        error: AppColors.danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgMid,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading2(null),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      cardTheme: CardTheme(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: AppTypography.label(null),
        hintStyle: AppTypography.body(null),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.buttonText(null),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: AppTypography.heading2(null),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgSurface,
        contentTextStyle: AppTypography.body(null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: AppColors.borderLight,
    );
  }
}
