import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dynamic palette switch
  static bool _isDark = false;
  static bool get isDark => _isDark;
  static void setDarkMode(bool dark) => _isDark = dark;

  // ============ BACKGROUNDS ============
  static Color get bgDeep => _isDark ? const Color(0xFF111118) : const Color(0xFFF7F7FB);
  static Color get bgMid => _isDark ? const Color(0xFF16161F) : const Color(0xFFEEEDF7);
  static Color get bgSurface => _isDark ? const Color(0xFF1A1A24) : const Color(0xFFFFFFFF);
  static Color get bgCard => _isDark ? const Color(0xFF1A1A24) : const Color(0xFFFFFFFF);
  static Color get bgElevated => _isDark ? const Color(0xFF22222E) : const Color(0xFFFFFFFF);

  // ============ BRAND / PRIMARY ============
  static Color get primary => _isDark ? const Color(0xFF8B7FFF) : const Color(0xFF5B4FE9);
  static Color get primaryHover => _isDark ? const Color(0xFFA499FF) : const Color(0xFF4A3FD4);
  static Color get primaryTint => _isDark ? const Color(0xFF2A2645) : const Color(0xFFEDEBFC);
  static Color get primaryLight => _isDark ? const Color(0xFFA499FF) : const Color(0xFF4A3FD4);
  static Color get primaryDark => _isDark ? const Color(0xFF6B5FE0) : const Color(0xFF4A3FD4);

  // ============ TEXT ============
  static Color get textPrimary => _isDark ? const Color(0xFFF1F1F6) : const Color(0xFF1B1B2A);
  static Color get textSecondary => _isDark ? const Color(0xFF9A9AB0) : const Color(0xFF5C5C72);
  static Color get textMuted => _isDark ? const Color(0xFF5A5A6E) : const Color(0xFFA0A0B2);
  static Color get textDisabled => _isDark ? const Color(0xFF3A3A4A) : const Color(0xFFD0D0DA);

  // ============ BORDERS ============
  static Color get borderLight => _isDark ? const Color(0xFF2C2C3A) : const Color(0xFFE4E4EE);
  static Color get borderMedium => _isDark ? const Color(0xFF3A3A4A) : const Color(0xFFD0D0DA);
  static Color get borderFocus => _isDark ? const Color(0xFF8B7FFF) : const Color(0xFF5B4FE9);

  // ============ SEMANTIC ============
  static Color get success => _isDark ? const Color(0xFF3DDC97) : const Color(0xFF1E9E6B);
  static Color get successTint => _isDark ? const Color(0xFF173229) : const Color(0xFFE4F7EE);
  static Color get warning => _isDark ? const Color(0xFFF5A623) : const Color(0xFFD48806);
  static Color get warningTint => _isDark ? const Color(0xFF332508) : const Color(0xFFFFF4DE);
  static Color get danger => _isDark ? const Color(0xFFFF6B5E) : const Color(0xFFDB4437);
  static Color get dangerTint => _isDark ? const Color(0xFF3A1A17) : const Color(0xFFFDEBEA);
  static Color get info => _isDark ? const Color(0xFF5B9DF9) : const Color(0xFF2F80ED);
  static Color get infoLight => _isDark ? const Color(0xFF7BB3FA) : const Color(0xFF5B9DF9);
  static Color get infoTint => _isDark ? const Color(0xFF182A3E) : const Color(0xFFEAF2FE);

  // ============ REVENUE ============
  static Color get revenue => _isDark ? const Color(0xFF3DDC97) : const Color(0xFF1E9E6B);
  static Color get expense => _isDark ? const Color(0xFFFF6B5E) : const Color(0xFFDB4437);

  // ============ KANBAN STAGES ============
  static Color get stageNew => _isDark ? const Color(0xFF5B9DF9) : const Color(0xFF2F80ED);
  static Color get stageContacted => _isDark ? const Color(0xFF8B7FFF) : const Color(0xFF5B4FE9);
  static Color get stageQualified => _isDark ? const Color(0xFF3DDC97) : const Color(0xFF1E9E6B);
  static Color get stageProposal => _isDark ? const Color(0xFFF5A623) : const Color(0xFFD48806);
  static Color get stageNegotiation => _isDark ? const Color(0xFFFF8C5E) : const Color(0xFFE07A00);
  static Color get stageWon => _isDark ? const Color(0xFF3DDC97) : const Color(0xFF1E9E6B);
  static Color get stageLost => _isDark ? const Color(0xFFFF6B5E) : const Color(0xFFDB4437);

  // ============ PRIORITY ============
  static Color get priorityLow => _isDark ? const Color(0xFF5A5A6E) : const Color(0xFFA0A0B2);
  static Color get priorityMedium => _isDark ? const Color(0xFF5B9DF9) : const Color(0xFF2F80ED);
  static Color get priorityHigh => _isDark ? const Color(0xFFF5A623) : const Color(0xFFD48806);
  static Color get priorityUrgent => _isDark ? const Color(0xFFFF6B5E) : const Color(0xFFDB4437);
}

class AppTypography {
  AppTypography._();

  static const _family = 'Inter';

  static TextStyle displayLarge([BuildContext? _]) => TextStyle(
        fontFamily: _family, fontSize: 28, fontWeight: FontWeight.w700,
        letterSpacing: -0.5, color: AppColors.textPrimary, height: 1.15,
      );

  static TextStyle displayMedium([BuildContext? _]) => TextStyle(
        fontFamily: _family, fontSize: 24, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, color: AppColors.textPrimary, height: 1.2,
      );

  static TextStyle heading1([BuildContext? _]) => TextStyle(
        fontFamily: _family, fontSize: 20, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.25,
      );

  static TextStyle heading2([BuildContext? _]) => TextStyle(
        fontFamily: _family, fontSize: 16, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.3,
      );

  static TextStyle heading3([BuildContext? _]) => TextStyle(
        fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, height: 1.35,
      );

  static TextStyle body([BuildContext? _]) => TextStyle(
        fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary, height: 1.5,
      );

  static TextStyle bodyMedium([BuildContext? _]) => TextStyle(
        fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w500,
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
        color: AppColors.revenue, letterSpacing: -0.3,
      );

  static TextStyle statValue([BuildContext? _]) => TextStyle(
        fontFamily: _family, fontSize: 28, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.5,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF5B4FE9),
        secondary: Color(0xFF4A3FD4),
        surface: Colors.white,
        error: Color(0xFFDB4437),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white, elevation: 0, centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE4E4EE)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE4E4EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE4E4EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5B4FE9), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B4FE9),
          foregroundColor: Colors.white, elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF5C5C72),
          side: const BorderSide(color: Color(0xFFE4E4EE)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerColor: const Color(0xFFE4E4EE),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF111118),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8B7FFF),
        secondary: Color(0xFFA499FF),
        surface: Color(0xFF1A1A24),
        error: Color(0xFFFF6B5E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF16161F), elevation: 0, centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A24), elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2C2C3A)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFF1A1A24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2C2C3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2C2C3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8B7FFF), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B7FFF),
          foregroundColor: Colors.white, elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF9A9AB0),
          side: const BorderSide(color: Color(0xFF2C2C3A)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerColor: const Color(0xFF2C2C3A),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A24),
        contentTextStyle: const TextStyle(color: Color(0xFFF1F1F6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============ HELPERS ============
  static Color stageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'new_lead': case 'new lead': return AppColors.stageNew;
      case 'contacted': return AppColors.stageContacted;
      case 'qualified': return AppColors.stageQualified;
      case 'proposal_sent': case 'proposal sent': return AppColors.stageProposal;
      case 'negotiation': return AppColors.stageNegotiation;
      case 'won': return AppColors.stageWon;
      case 'lost': return AppColors.stageLost;
      default: return AppColors.textMuted;
    }
  }

  static Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low': return AppColors.priorityLow;
      case 'medium': return AppColors.priorityMedium;
      case 'high': return AppColors.priorityHigh;
      case 'urgent': return AppColors.priorityUrgent;
      default: return AppColors.textMuted;
    }
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid': case 'accepted': case 'signed': case 'completed': case 'active':
        return AppColors.success;
      case 'draft': case 'planning': return AppColors.textMuted;
      case 'sent': case 'viewed': case 'in_progress': case 'in progress': case 'review':
        return AppColors.info;
      case 'overdue': case 'expired': case 'cancelled': case 'rejected':
      case 'on_hold': case 'on hold': return AppColors.danger;
      case 'partial': return AppColors.warning;
      default: return AppColors.textMuted;
    }
  }
}

// Currency helper — reads from AppSettings for the whole app
class AppCurrency {
  static String _code = 'INR';
  static String get code => _code;
  static void setCode(String c) => _code = c;

  static String get symbol {
    switch (_code) {
      case 'INR': return '₹';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      default: return '\$';
    }
  }

  static String format(double amount) {
    if (_code == 'INR') {
      final abs = amount.abs();
      final parts = abs.toStringAsFixed(0);
      final formatted = _indianCommaFormat(parts);
      return '$symbol$formatted';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String formatDecimal(double amount) {
    if (_code == 'INR') {
      final abs = amount.abs();
      final parts = abs.toStringAsFixed(2);
      final intPart = parts.split('.')[0];
      final decPart = parts.split('.')[1];
      final formatted = _indianCommaFormat(intPart);
      return '$symbol$formatted.$decPart';
    }
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String _indianCommaFormat(String numberStr) {
    if (numberStr.length <= 3) return numberStr;
    final last3 = numberStr.substring(numberStr.length - 3);
    final rest = numberStr.substring(0, numberStr.length - 3);
    // Add commas every 2 digits for the rest
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) buffer.write(',');
      buffer.write(rest[i]);
    }
    return '$buffer,$last3';
  }

  static String formatCompact(double value) {
    if (value >= 10000000) return '$symbol${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '$symbol${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '$symbol${(value / 1000).toStringAsFixed(1)}K';
    return '$symbol${value.toStringAsFixed(0)}';
  }

  static List<String> get supportedCurrencies => ['INR', 'USD', 'EUR', 'GBP', 'JPY'];
}
