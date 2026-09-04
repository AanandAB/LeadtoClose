import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leadtoclose/app.dart';
import 'package:leadtoclose/services/storage_service.dart';
import 'package:leadtoclose/providers.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await Hive.initFlutter();
    final storage = StorageService();
    await storage.init();

    await tester.pumpWidget(ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
      child: const NaroApp(),
    ));

    await tester.pumpAndSettle();

    // App should render without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
