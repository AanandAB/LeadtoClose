import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'services/storage_service.dart';
import 'providers.dart';

/// Box names shipped as bundled seed data (mirrors StorageService's box list).
const _seedBoxes = [
  'settings',
  'leads',
  'clients',
  'projects',
  'tasks',
  'invoices',
  'quotes',
  'contracts',
  'time_entries',
  'documents',
  'communications',
  'events',
  'milestones',
  'referral_coupons',
  'checklists',
  'sync_meta',
];

/// Seeds the Hive directory with bundled data on first launch.
///
/// If the app has never been initialised on this machine (no `settings.hive`),
/// the shipped dataset is copied into the Hive directory so the app opens
/// preloaded. On subsequent launches (or after the user creates their own data)
/// this is a no-op, so it never overwrites real user data.
Future<void> _seedIfFirstRun() async {
  // Same directory Hive.initFlutter() targets (getApplicationDocumentsDirectory).
  final dir = await getApplicationDocumentsDirectory();
  final settingsFile = File('${dir.path}/settings.hive');
  if (settingsFile.existsSync()) return;

  for (final name in _seedBoxes) {
    try {
      final data = await rootBundle.load('assets/seed/$name.hive');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File('${dir.path}/$name.hive').writeAsBytes(bytes, flush: true);
    } catch (_) {
      // Seed asset missing/empty — Hive will create a fresh empty box on open.
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await _seedIfFirstRun();
  final storage = StorageService();
  await storage.init();

  runApp(ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: const FreelanceHubApp(),
  ));
}
