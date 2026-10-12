import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase Unit Tests', () {
    test('instantiates successfully with in-memory database', () async {
      final decks = await db.select(db.decks).get();
      expect(decks, isEmpty);
    });

    test(
      'inserts Deck, associated Cards, and ReviewLogs successfully',
      () async {
        final now = DateTime.now().toUtc();

        final deckId = await db
            .into(db.decks)
            .insert(
              const DecksCompanion(
                name: Value('Spanish Vocabulary'),
                description: Value('Basic vocab for Spanish'),
              ),
            );
        expect(deckId, greaterThan(0));

        final cardId = await db
            .into(db.cards)
            .insert(
              CardsCompanion.insert(
                deckId: deckId,
                front: 'Hola',
                back: 'Hello',
                due: now,
              ),
            );
        expect(cardId, greaterThan(0));

        final logId = await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: cardId,
                rating: 3,
                state: 0,
                due: now,
                stability: 2.5,
                difficulty: 4.0,
                elapsedDays: 0,
                lastElapsedDays: 0,
                scheduledDays: 1,
                reviewedAt: now,
              ),
            );
        expect(logId, greaterThan(0));

        final storedDeck = await (db.select(
          db.decks,
        )..where((t) => t.id.equals(deckId))).getSingle();
        expect(storedDeck.name, 'Spanish Vocabulary');

        final storedCard = await (db.select(
          db.cards,
        )..where((t) => t.id.equals(cardId))).getSingle();
        expect(storedCard.front, 'Hola');
        expect(storedCard.stability, 0.0); // default value
        expect(storedCard.state, 0); // default value

        final storedLog = await (db.select(
          db.reviewLogs,
        )..where((t) => t.id.equals(logId))).getSingle();
        expect(storedLog.rating, 3);
        expect(storedLog.cardId, cardId);
      },
    );

    test('enforces foreign key constraint on insertion', () async {
      final now = DateTime.now().toUtc();

      expect(
        () async => db
            .into(db.cards)
            .insert(
              CardsCompanion.insert(
                deckId: 9999, // Non-existent deck
                front: 'Orphan Front',
                back: 'Orphan Back',
                due: now,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('cascades delete from Deck to Cards and ReviewLogs', () async {
      final now = DateTime.now().toUtc();

      final deckId = await db
          .into(db.decks)
          .insert(const DecksCompanion(name: Value('Biology')));

      final cardId = await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'Cell',
              back: 'Basic structural unit of life',
              due: now,
            ),
          );

      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: cardId,
              rating: 4,
              state: 0,
              due: now,
              stability: 5.0,
              difficulty: 3.0,
              elapsedDays: 0,
              lastElapsedDays: 0,
              scheduledDays: 4,
              reviewedAt: now,
            ),
          );

      // Verify records exist
      final cardsBefore = await (db.select(
        db.cards,
      )..where((t) => t.deckId.equals(deckId))).get();
      expect(cardsBefore, hasLength(1));

      final logsBefore = await (db.select(
        db.reviewLogs,
      )..where((t) => t.cardId.equals(cardId))).get();
      expect(logsBefore, hasLength(1));

      // Delete the parent Deck
      final deletedCount = await (db.delete(
        db.decks,
      )..where((t) => t.id.equals(deckId))).go();
      expect(deletedCount, equals(1));

      // Verify Deck is gone
      final deckAfter = await (db.select(
        db.decks,
      )..where((t) => t.id.equals(deckId))).get();
      expect(deckAfter, isEmpty);

      // Verify associated Cards were cascaded and deleted
      final cardsAfter = await (db.select(
        db.cards,
      )..where((t) => t.id.equals(cardId))).get();
      expect(cardsAfter, isEmpty);

      // Verify associated ReviewLogs were cascaded and deleted
      final logsAfter = await (db.select(
        db.reviewLogs,
      )..where((t) => t.cardId.equals(cardId))).get();
      expect(logsAfter, isEmpty);
    });

    test(
      'reactive queries (watch) emit updated data on insertions and deletions',
      () async {
        final stream = db.select(db.decks).watch();

        final expectation = expectLater(
          stream,
          emitsInOrder([isEmpty, hasLength(1), isEmpty]),
        );

        // First emission is initial empty list (happens on watch listen)
        await pumpEventQueue();

        // Insert deck triggers second emission
        final deckId = await db
            .into(db.decks)
            .insert(const DecksCompanion(name: Value('Reactive Test Deck')));
        await pumpEventQueue();

        // Delete deck triggers third emission
        await (db.delete(db.decks)..where((t) => t.id.equals(deckId))).go();
        await pumpEventQueue();

        await expectation;
      },
    );

    test(
      'getSetting, setSetting, and watchSetting operate correctly',
      () async {
        expect(await db.getSetting('unknown_key'), equals(null));

        await db.setSetting('theme_mode', 'dark');
        expect(await db.getSetting('theme_mode'), equals('dark'));

        // Update existing key
        await db.setSetting('theme_mode', 'light');
        expect(await db.getSetting('theme_mode'), equals('light'));

        // Watch setting
        final stream = db.watchSetting('reminder_enabled');
        final expectation = expectLater(
          stream,
          emitsInOrder([equals(null), 'true']),
        );

        await pumpEventQueue();
        await db.setSetting('reminder_enabled', 'true');
        await pumpEventQueue();

        await expectation;
      },
    );
  });
}
