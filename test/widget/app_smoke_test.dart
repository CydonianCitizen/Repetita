import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/app.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';

void main() {
  testWidgets('RepetitaApp boots and renders Scaffold under ProviderScope', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const RepetitaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.text('repetita'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
