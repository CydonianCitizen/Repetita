import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/cards/data/cards_dao.dart';

void main() {
  late AppDatabase db;
  late CardsDao cardsDao;
  late int deck1Id;
  late int deck2Id;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cardsDao = db.cardsDao;

    deck1Id = await db.decksDao.createDeck(name: 'Deck 1');
    deck2Id = await db.decksDao.createDeck(name: 'Deck 2');
  });

  tearDown(() async {
    await db.close();
  });

  group('CardsDao Unit Tests', () {
    test('createCard assigns correct initial FSRS default values', () async {
      final before = DateTime.now().toUtc();
      final cardId = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Question 1',
        back: 'Answer 1',
      );

      expect(cardId, greaterThan(0));

      final cards = await cardsDao.getCardsByDeck(deck1Id);
      expect(cards, hasLength(1));

      final card = cards.first;
      expect(card.deckId, equals(deck1Id));
      expect(card.front, equals('Question 1'));
      expect(card.back, equals('Answer 1'));
      expect(card.state, equals(0)); // New
      expect(card.stability, equals(0.0));
      expect(card.difficulty, equals(0.0));
      expect(card.reps, equals(0));
      expect(card.lapses, equals(0));
      expect(card.lastReview, isNull);
      expect(card.due.difference(before).inSeconds.abs(), lessThanOrEqualTo(2));
    });

    test(
      'getCardsByDeck filters by deck and orders by createdAt/id DESC',
      () async {
        final card1Id = await cardsDao.createCard(
          deckId: deck1Id,
          front: 'Card 1',
          back: 'Ans 1',
        );
        final card2Id = await cardsDao.createCard(
          deckId: deck1Id,
          front: 'Card 2',
          back: 'Ans 2',
        );
        await cardsDao.createCard(
          deckId: deck2Id,
          front: 'Deck 2 Card',
          back: 'Ans D2',
        );

        final deck1Cards = await cardsDao.getCardsByDeck(deck1Id);
        expect(deck1Cards, hasLength(2));
        expect(deck1Cards[0].id, equals(card2Id)); // newest first
        expect(deck1Cards[1].id, equals(card1Id));

        final deck2Cards = await cardsDao.getCardsByDeck(deck2Id);
        expect(deck2Cards, hasLength(1));
        expect(deck2Cards.first.front, equals('Deck 2 Card'));
      },
    );

    test('watchCardsByDeck emits updates when cards are inserted', () async {
      final stream = cardsDao.watchCardsByDeck(deck1Id);
      final expectation = expectLater(stream, emits(hasLength(1)));

      await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Stream Front',
        back: 'Stream Back',
      );

      await expectation;
    });

    test('getDueCards returns cards due before cutoff or in New state ordered by due ASC', () async {
      final now = DateTime.now().toUtc();

      // Card 1: Review card overdue (due 2 hours ago)
      final card1Id = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Overdue',
        back: 'Ans',
      );
      await (db.update(db.cards)..where((t) => t.id.equals(card1Id))).write(
        CardsCompanion(
          state: const Value(2), // Review
          due: Value(now.subtract(const Duration(hours: 2))),
        ),
      );

      // Card 2: New card with future due date -> still due because state == 0
      final card2Id = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'New Card Future Due',
        back: 'Ans',
      );
      await (db.update(db.cards)..where((t) => t.id.equals(card2Id))).write(
        CardsCompanion(
          state: const Value(0), // New
          due: Value(now.add(const Duration(days: 5))),
        ),
      );

      // Card 3: Review card due in 3 days -> NOT due
      final card3Id = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Future Review',
        back: 'Ans',
      );
      await (db.update(db.cards)..where((t) => t.id.equals(card3Id))).write(
        CardsCompanion(
          state: const Value(2), // Review
          due: Value(now.add(const Duration(days: 3))),
        ),
      );

      final dueCards = await cardsDao.getDueCards(deck1Id, now);
      expect(dueCards, hasLength(2));
      expect(dueCards[0].front, equals('Overdue'));
      expect(dueCards[1].front, equals('New Card Future Due'));
    });

    test('updateCardContent and deleteCard operate correctly', () async {
      final cardId = await cardsDao.createCard(
        deckId: deck1Id,
        front: 'Original Front',
        back: 'Original Back',
      );

      final updated = await cardsDao.updateCardContent(
        id: cardId,
        front: 'Modified Front',
        back: 'Modified Back',
      );
      expect(updated, isTrue);

      final cards = await cardsDao.getCardsByDeck(deck1Id);
      expect(cards.first.front, equals('Modified Front'));
      expect(cards.first.back, equals('Modified Back'));

      final deleted = await cardsDao.deleteCard(cardId);
      expect(deleted, equals(1));

      final emptyCards = await cardsDao.getCardsByDeck(deck1Id);
      expect(emptyCards, isEmpty);
    });
  });
}
