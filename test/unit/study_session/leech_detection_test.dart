import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_models.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/cards/data/cards_dao.dart';
import 'package:repetita/src/features/study_session/data/study_session_dao.dart';
import 'package:repetita/src/features/study_session/presentation/controllers/study_session_controller.dart';
import 'package:repetita/src/features/tags/data/tags_dao.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    testDeckId = await db.decksDao.createDeck(name: 'Leech Deck');

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        studySessionDaoProvider.overrideWithValue(db.studySessionDao),
        cardsDaoProvider.overrideWithValue(db.cardsDao),
        tagsDaoProvider.overrideWithValue(db.tagsDao),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('Leech Detection Tests', () {
    test('Tagging mode attaches leech tag when card reaches lapse threshold on Again', () async {
      // Configure leech threshold = 3, action = tag
      await db.setSetting('leech_threshold', '3');
      await db.setSetting('leech_action', 'tag');

      final cardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Hard Question',
        back: 'Hard Answer',
      );

      // Pre-set lapses to 2, state to Review (2)
      await (db.update(db.cards)..where((tbl) => tbl.id.equals(cardId))).write(
        CardsCompanion(
          state: const Value(2),
          reps: const Value(5),
          lapses: const Value(2),
          stability: const Value(2.0),
          difficulty: const Value(7.0),
        ),
      );

      final controllerProvider = studySessionControllerProvider(testDeckId);
      await container.read(controllerProvider.future);

      // Rating Again -> lapse count becomes 3 (threshold reached!)
      await container.read(controllerProvider.notifier).submitRating(Rating.again);

      // Verify 'leech' tag is created and attached to card
      final cardTags = await db.tagsDao.getTagsForCard(cardId);
      expect(cardTags.any((t) => t.name == 'leech'), isTrue);

      // In 'tag' mode, card is NOT suspended
      final updatedCard = await db.cardsDao.getCardById(cardId);
      expect(updatedCard?.isSuspended, isFalse);
    });

    test('Tag and Suspend mode attaches leech tag AND suspends card', () async {
      await db.setSetting('leech_threshold', '2');
      await db.setSetting('leech_action', 'tag_and_suspend');

      final cardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Severe Question',
        back: 'Severe Answer',
      );

      // Pre-set lapses to 1, state to Review (2)
      await (db.update(db.cards)..where((tbl) => tbl.id.equals(cardId))).write(
        CardsCompanion(
          state: const Value(2),
          reps: const Value(4),
          lapses: const Value(1),
          stability: const Value(1.5),
          difficulty: const Value(8.0),
        ),
      );

      final controllerProvider = studySessionControllerProvider(testDeckId);
      await container.read(controllerProvider.future);

      // Rating Again -> lapses becomes 2
      await container.read(controllerProvider.notifier).submitRating(Rating.again);

      // Verify leech tag attached AND card is suspended
      final cardTags = await db.tagsDao.getTagsForCard(cardId);
      expect(cardTags.any((t) => t.name == 'leech'), isTrue);

      final updatedCard = await db.cardsDao.getCardById(cardId);
      expect(updatedCard?.isSuspended, isTrue);
    });

    test('StatsDao.getLeechCardsCount returns correct count based on threshold', () async {
      final card1 = await db.cardsDao.createCard(deckId: testDeckId, front: 'Q1', back: 'A1');
      final card2 = await db.cardsDao.createCard(deckId: testDeckId, front: 'Q2', back: 'A2');
      final card3 = await db.cardsDao.createCard(deckId: testDeckId, front: 'Q3', back: 'A3');

      await (db.update(db.cards)..where((tbl) => tbl.id.equals(card1))).write(
        const CardsCompanion(lapses: Value(8)),
      );
      await (db.update(db.cards)..where((tbl) => tbl.id.equals(card2))).write(
        const CardsCompanion(lapses: Value(10)),
      );
      await (db.update(db.cards)..where((tbl) => tbl.id.equals(card3))).write(
        const CardsCompanion(lapses: Value(3)),
      );

      final countDefault = await db.statsDao.getLeechCardsCount(deckId: testDeckId);
      expect(countDefault, equals(2)); // card1 (8) and card2 (10) >= 8

      final countLow = await db.statsDao.getLeechCardsCount(deckId: testDeckId, threshold: 3);
      expect(countLow, equals(3)); // card1, card2, card3 >= 3
    });
  });
}
