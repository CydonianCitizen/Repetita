import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/decks/data/decks_dao.dart';

void main() {
  late AppDatabase db;
  late DecksDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = db.decksDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('DecksDao Unit Tests', () {
    test('creates and retrieves a deck with correct counts', () async {
      final deckId = await dao.createDeck(
        name: 'Math',
        description: 'Calculus and Algebra',
      );
      expect(deckId, greaterThan(0));

      final decks = await dao.watchAllDecksWithCounts().first;
      expect(decks, hasLength(1));
      expect(decks.first.deck.name, equals('Math'));
      expect(decks.first.deck.description, equals('Calculus and Algebra'));
      expect(decks.first.totalCards, equals(0));
      expect(decks.first.dueCards, equals(0));
    });

    test('updates deck details accurately', () async {
      final deckId = await dao.createDeck(name: 'Initial Name');
      final updated = await dao.updateDeck(
        id: deckId,
        name: 'Updated Name',
        description: 'New Description',
      );
      expect(updated, isTrue);

      final decks = await dao.watchAllDecksWithCounts().first;
      expect(decks.first.deck.name, equals('Updated Name'));
      expect(decks.first.deck.description, equals('New Description'));
    });

    test('deletes deck and cascades associated cards', () async {
      final deckId = await dao.createDeck(name: 'To Delete');
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'Q',
              back: 'A',
              due: DateTime.now().toUtc(),
            ),
          );

      final deletedRows = await dao.deleteDeck(deckId);
      expect(deletedRows, equals(1));

      final decks = await dao.watchAllDecksWithCounts().first;
      expect(decks, isEmpty);

      final remainingCards = await db.select(db.cards).get();
      expect(remainingCards, isEmpty);
    });

    test('calculates totalCards and dueCards accurately across card states', () async {
      final deckId = await dao.createDeck(name: 'Deck with Cards');
      final now = DateTime.now().toUtc();

      // Card 1: New card (state = 0, due tomorrow) -> counts as due because state == 0
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'New Card',
              back: 'Ans 1',
              due: now.add(const Duration(days: 1)),
              state: const Value(0),
            ),
          );

      // Card 2: Review card overdue (state = 2, due yesterday) -> counts as due
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'Overdue Card',
              back: 'Ans 2',
              due: now.subtract(const Duration(days: 1)),
              state: const Value(2),
            ),
          );

      // Card 3: Review card not due (state = 2, due in 5 days) -> not due
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              deckId: deckId,
              front: 'Future Card',
              back: 'Ans 3',
              due: now.add(const Duration(days: 5)),
              state: const Value(2),
            ),
          );

      final decks = await dao.watchAllDecksWithCounts().first;
      expect(decks, hasLength(1));
      expect(decks.first.totalCards, equals(3));
      expect(decks.first.dueCards, equals(2));
    });
  });
}
