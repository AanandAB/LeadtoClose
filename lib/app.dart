import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'providers.dart';

class NaroApp extends ConsumerWidget {
  const NaroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    // Sync the AppColors palette with the current dark mode setting
    AppColors.setDarkMode(settings.isDarkMode);

    return MaterialApp.router(
      title: 'Naro',
      debugShowCheckedModeBanner: false,
      theme: settings.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
