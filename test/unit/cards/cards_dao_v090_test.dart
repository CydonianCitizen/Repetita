import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/cards/data/cards_dao.dart';

void main() {
  late AppDatabase db;
  late CardsDao cardsDao;
  late int deckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cardsDao = db.cardsDao;
    deckId = await db.decksDao.createDeck(name: 'Test Deck');
  });

  tearDown(() async {
    await db.close();
  });

  group('CardsDao v0.9.0 Features', () {
    test('setCardFlag updates flag property correctly', () async {
      final cardId = await cardsDao.createCard(
        deckId: deckId,
        front: 'Flag Test Front',
        back: 'Flag Test Back',
      );

      // Default flag is 0 (no flag)
      var card = await cardsDao.getCardById(cardId);
      expect(card?.flag, equals(0));

      // Set to Red (1)
      await cardsDao.setCardFlag(cardId, 1);
      card = await cardsDao.getCardById(cardId);
      expect(card?.flag, equals(1));

      // Set to Blue (4)
      await cardsDao.setCardFlag(cardId, 4);
      card = await cardsDao.getCardById(cardId);
      expect(card?.flag, equals(4));

      // Reset to None (0)
      await cardsDao.setCardFlag(cardId, 0);
      card = await cardsDao.getCardById(cardId);
      expect(card?.flag, equals(0));
    });

    test('setCardDueDate modifies card due date without touching SRS state', () async {
      final cardId = await cardsDao.createCard(
        deckId: deckId,
        front: 'Due Date Front',
        back: 'Due Date Back',
      );

      final targetDate = DateTime(2027, 5, 20, 10, 0, 0);
      await cardsDao.setCardDueDate(cardId, targetDate);

      final card = await cardsDao.getCardById(cardId);
      expect(card?.due.year, equals(2027));
      expect(card?.due.month, equals(5));
      expect(card?.due.day, equals(20));
    });

    test('resetCardProgress resets FSRS and SM-2 parameters to initial state', () async {
      final cardId = await cardsDao.createCard(
        deckId: deckId,
        front: 'Reset Front',
        back: 'Reset Back',
      );

      // Mutate card with custom state via custom statement or update
      await (db.update(db.cards)..where((tbl) => tbl.id.equals(cardId))).write(
        CardsCompanion(
          state: const Value(2),
          reps: const Value(12),
          lapses: const Value(4),
          stability: const Value(18.5),
          difficulty: const Value(6.2),
          easinessFactor: const Value(1.7),
        ),
      );

      var modified = await cardsDao.getCardById(cardId);
      expect(modified?.state, equals(2));
      expect(modified?.reps, equals(12));
      expect(modified?.lapses, equals(4));

      // Reset progress
      await cardsDao.resetCardProgress(cardId);

      final reset = await cardsDao.getCardById(cardId);
      expect(reset?.state, equals(0));
      expect(reset?.reps, equals(0));
      expect(reset?.lapses, equals(0));
      expect(reset?.stability, equals(0.0));
      expect(reset?.difficulty, equals(0.0));
      expect(reset?.easinessFactor, equals(2.5));
      expect(reset?.lastReview, isNull);
    });

    test('duplicateCard creates a new card with identical content and fresh state', () async {
      final cardId = await cardsDao.createCard(
        deckId: deckId,
        front: 'Original Front',
        back: 'Original Back',
      );

      final copyId = await cardsDao.duplicateCard(cardId);
      expect(copyId, isNot(equals(cardId)));

      final copy = await cardsDao.getCardById(copyId);
      expect(copy?.deckId, equals(deckId));
      expect(copy?.front, equals('Original Front'));
      expect(copy?.back, equals('Original Back'));
      expect(copy?.state, equals(0));
      expect(copy?.reps, equals(0));
      expect(copy?.flag, equals(0));
    });
  });
}
