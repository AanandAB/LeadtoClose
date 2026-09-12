import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'providers.dart';
import 'widgets/app_snackbars.dart';

class FreelanceHubApp extends ConsumerStatefulWidget {
  const FreelanceHubApp({super.key});

  @override
  ConsumerState<FreelanceHubApp> createState() => _FreelanceHubAppState();
}

class _FreelanceHubAppState extends ConsumerState<FreelanceHubApp> {
  bool _syncHooked = false;
  bool _portalSyncHooked = false;

  void _hookLeadSync() {
    if (_syncHooked) return;
    _syncHooked = true;
    final sync = ref.read(leadSyncProvider);
    sync.onNewLead = (remote) {
      if (!mounted) return;
      showAppSnackbar(
        context,
        '🌐 New website lead: ${remote.name} (${remote.email})',
        type: AppSnackbarType.success,
      );
    };
    sync.onError = (error) {
      if (!mounted) return;
      ref.read(syncErrorProvider.notifier).state = error;
    };
    sync.onSynced = (t) {
      if (!mounted) return;
      ref.read(lastSyncProvider.notifier).state = t;
    };
  }

  void _hookPortalSync() {
    if (_portalSyncHooked) return;
    _portalSyncHooked = true;
    ref.read(portalSyncProvider);
    final events = ref.read(portalEventsProvider);
    events.onImported = (count) {
      if (!mounted || count <= 0) return;
      showAppSnackbar(
        context,
        '$count client action(s) synced from the portal',
        type: AppSnackbarType.info,
      );
    };
    events.onError = (error) {
      if (!mounted) return;
      ref.read(portalSyncStatusProvider.notifier).state = error;
    };
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    // Sync the AppColors palette with the current dark mode setting
    AppColors.setDarkMode(settings.isDarkMode);
    AppCurrency.setCode(settings.currency.isNotEmpty ? settings.currency : 'INR');

    // Hook the live lead sync once providers are ready.
    _hookLeadSync();
    _hookPortalSync();

    return MaterialApp.router(
      title: 'FreelanceHub',
      debugShowCheckedModeBanner: false,
      theme: settings.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
