
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final storage = StorageService();
  await storage.init();

  runApp(ProviderScope(
    overrides: [storageServiceProvider.overrideWithValue(storage)],
    child: const LeadToCloseApp(),
  ));
}
