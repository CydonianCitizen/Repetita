import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/decks/data/sample_deck_seeder.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('SampleDeckSeeder Tests', () {
    test('seeds sample deck and associated basic and cloze cards', () async {
      final deckId = await SampleDeckSeeder.seed(db);
      expect(deckId, greaterThan(0));

      final decks = await db.decksDao.watchAllDecksWithCounts().first;
      expect(decks, hasLength(1));
      expect(decks.first.deck.name, equals(SampleDeckSeeder.sampleDeckName));
      expect(decks.first.totalCards, equals(8));
      expect(decks.first.dueCards, equals(8));

      final cards = await db.cardsDao.getCardsByDeck(deckId);
      expect(cards, hasLength(8));

      final basicCards = cards.where((c) => c.clozeIndex == null).toList();
      final cloze1Cards = cards.where((c) => c.clozeIndex == 1).toList();
      final cloze2Cards = cards.where((c) => c.clozeIndex == 2).toList();

      expect(basicCards, hasLength(4));
      expect(cloze1Cards, hasLength(2));
      expect(cloze2Cards, hasLength(2));
    });
  });
}
