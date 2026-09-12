import 'package:flutter/material.dart';

/// Shared SnackBar helpers — consistent toast messaging across the app.
void showAppSnackbar(
  BuildContext context,
  String message, {
  AppSnackbarType type = AppSnackbarType.info,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(_iconFor(type), color: _colorFor(type), size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: _bgFor(context, type),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

enum AppSnackbarType { success, error, warning, info }

IconData _iconFor(AppSnackbarType type) {
  switch (type) {
    case AppSnackbarType.success:
      return Icons.check_circle_rounded;
    case AppSnackbarType.error:
      return Icons.error_rounded;
    case AppSnackbarType.warning:
      return Icons.warning_amber_rounded;
    case AppSnackbarType.info:
      return Icons.info_outline_rounded;
  }
}

Color _colorFor(AppSnackbarType type) {
  switch (type) {
    case AppSnackbarType.success:
      return Colors.greenAccent;
    case AppSnackbarType.error:
      return Colors.redAccent;
    case AppSnackbarType.warning:
      return Colors.orangeAccent;
    case AppSnackbarType.info:
      return Colors.lightBlueAccent;
  }
}

Color _bgFor(BuildContext context, AppSnackbarType type) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final base = dark ? const Color(0xFF1E2430) : Colors.white;
  // Slight tint per type keeps the existing app aesthetic.
  return base;
}
