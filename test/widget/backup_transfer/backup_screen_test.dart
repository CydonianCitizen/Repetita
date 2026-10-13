import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/backup_transfer/presentation/backup_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: BackupScreen()),
    );
  }

  group('BackupScreen Widget Tests', () {
    testWidgets('renders all backup and interchange action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Backup & Transfer'), findsOneWidget);
      expect(find.text('Full Database Backup (JSON)'), findsOneWidget);
      expect(find.text('Flashcards Interchange (CSV)'), findsOneWidget);

      expect(find.byKey(const Key('export_json_button')), findsOneWidget);
      expect(find.byKey(const Key('restore_json_button')), findsOneWidget);
      expect(find.byKey(const Key('export_csv_button')), findsOneWidget);
      expect(find.byKey(const Key('import_csv_button')), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('import_anki_button')),
        200,
      );
      expect(find.byKey(const Key('import_anki_button')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('tapping export JSON generates backup and displays dialog', (
      tester,
    ) async {
      await db.decksDao.createDeck(name: 'Demo Deck');

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('export_json_button')));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Full Backup JSON'), findsOneWidget);
      expect(find.text('Backup exported successfully!'), findsOneWidget);
      expect(find.text('Copy to Clipboard'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Full Backup JSON'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('restoring valid JSON updates database and shows feedback', (
      tester,
    ) async {
      const backupJson = '''{
  "version": 1,
  "exportedAt": "2026-10-11T00:00:00.000Z",
  "decks": [
    {
      "id": 1,
      "name": "Restored Deck",
      "description": "Imported via JSON",
      "createdAt": "2026-10-11T00:00:00.000Z",
      "updatedAt": "2026-10-11T00:00:00.000Z"
    }
  ],
  "cards": [
    {
      "id": 1,
      "deckId": 1,
      "front": "Restored Front",
      "back": "Restored Back",
      "state": 0,
      "stability": 0.0,
      "difficulty": 0.0,
      "due": "2026-10-11T00:00:00.000Z",
      "lastReview": null,
      "reps": 0,
      "lapses": 0,
      "createdAt": "2026-10-11T00:00:00.000Z"
    }
  ],
  "reviewLogs": []
}''';

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('restore_json_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('json_input_field')),
        backupJson,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_restore_button')));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Backup restored successfully!'), findsOneWidget);

      final decksInDb = await db.select(db.decks).get();
      expect(decksInDb, hasLength(1));
      expect(decksInDb.first.name, equals('Restored Deck'));

      final cardsInDb = await db.select(db.cards).get();
      expect(cardsInDb, hasLength(1));
      expect(cardsInDb.first.front, equals('Restored Front'));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'tapping import Anki button interacts cleanly with file picker',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.byKey(const Key('import_anki_button')),
          200,
        );
        await tester.tap(find.byKey(const Key('import_anki_button')));
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );
  });
}
