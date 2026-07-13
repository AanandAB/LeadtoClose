
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4F46E5);

  // Background
  static const bgDeep = Color(0xFF0B1121);
  static const bgMid = Color(0xFF111827);
  static const bgSurface = Color(0xFF1E293B);
  static const bgCard = Color(0xFF1A2332);

  // Accents
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Text
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);

  // Borders
  static const borderLight = Color(0xFF334155);
  static const borderGlow = Color(0xFF6366F1);
}

class AppTypography {
  AppTypography._();

  static const _family = 'Inter';

  static TextStyle displayLarge([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 28, fontWeight: FontWeight.w700,
    letterSpacing: -0.5, color: AppColors.textPrimary, height: 1.2,
  );

  static TextStyle heading1([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.3,
  );

  static TextStyle heading2([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 18, fontWeight: FontWeight.w600,
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
    color: AppColors.textMuted, letterSpacing: 0.5,
  );

  static TextStyle label([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.5,
  );

  static TextStyle buttonText([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w600,
    color: Colors.white, letterSpacing: 0.3,
  );

  static TextStyle price([BuildContext? _]) => TextStyle(
    fontFamily: _family, fontSize: 20, fontWeight: FontWeight.w700,
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
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.borderLight.withOpacity(0.3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderLight.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.buttonText(null),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: AppColors.borderLight.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: AppTypography.heading2(null),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgSurface,
        contentTextStyle: AppTypography.body(null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: AppColors.borderLight.withOpacity(0.3),
    );
  }
}
