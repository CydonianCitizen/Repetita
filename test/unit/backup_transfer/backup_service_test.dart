import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/card_state.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_card.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/rating.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/record_log.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/backup_transfer/data/services/backup_service.dart';

void main() {
  late AppDatabase db;
  late BackupService backupService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    backupService = BackupService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupService Unit Tests', () {
    test('Full JSON Round-Trip Test preserves entities, FSRS states, and FK relationships', () async {
      final now = DateTime.now().toUtc();

      // 1. Seed database with decks, cards, review logs
      final deck1Id = await db.decksDao.createDeck(
        name: 'Deck 1',
        description: 'First test deck',
      );
      final deck2Id = await db.decksDao.createDeck(
        name: 'Deck 2',
        description: 'Second test deck',
      );

      final card1Id = await db.cardsDao.createCard(
        deckId: deck1Id,
        front: 'Front 1',
        back: 'Back 1',
      );
      await db.cardsDao.createCard(
        deckId: deck2Id,
        front: 'Front 2 {{c2::cloze}}',
        back: 'Back 2',
        clozeIndex: 2,
      );

      final tag1 = await db.tagsDao.getOrCreateTag('Medicine');
      await db.tagsDao.setCardTags(card1Id, [tag1]);

      // Record review on card 1 to create review log and modify FSRS state
      await db.studySessionDao.recordReview(
        cardId: card1Id,
        updatedCard: FsrsCard(
          state: CardState.review,
          stability: 4.25,
          difficulty: 6.1,
          due: now.add(const Duration(days: 4)),
          lastReview: now,
          reps: 2,
          lapses: 1,
        ),
        logSnapshot: ReviewLogSnapshot(
          rating: Rating.good,
          state: CardState.learning,
          due: now,
          stability: 4.25,
          difficulty: 6.1,
          elapsedDays: 1,
          lastElapsedDays: 1,
          scheduledDays: 4,
          reviewedAt: now,
        ),
      );

      // 2. Export to JSON
      final jsonString = await backupService.exportJsonPayload();
      expect(jsonString, isNotEmpty);
      expect(jsonString, contains('"version": 1'));
      expect(jsonString, contains('Deck 1'));
      expect(jsonString, contains('Deck 2'));
      expect(jsonString, contains('Front 1'));
      expect(jsonString, contains('Front 2'));
      expect(jsonString, contains('"clozeIndex": 2'));
      expect(jsonString, contains('Medicine'));

      // 3. Clear database
      await db.delete(db.cardTags).go();
      await db.delete(db.tags).go();
      await db.delete(db.reviewLogs).go();
      await db.delete(db.cards).go();
      await db.delete(db.decks).go();

      expect(await db.select(db.decks).get(), isEmpty);
      expect(await db.select(db.cards).get(), isEmpty);
      expect(await db.select(db.reviewLogs).get(), isEmpty);
      expect(await db.select(db.tags).get(), isEmpty);
      expect(await db.select(db.cardTags).get(), isEmpty);

      // 4. Import JSON
      await backupService.importJsonPayload(jsonString);

      // 5. Assert restored data
      final restoredDecks = await db.select(db.decks).get();
      final restoredCards = await db.select(db.cards).get();
      final restoredLogs = await db.select(db.reviewLogs).get();
      final restoredTags = await db.select(db.tags).get();
      final restoredCardTags = await db.select(db.cardTags).get();

      expect(restoredDecks, hasLength(2));
      expect(restoredCards, hasLength(2));
      expect(restoredLogs, hasLength(1));
      expect(restoredTags, hasLength(1));
      expect(restoredTags.first.name, equals('Medicine'));
      expect(restoredCardTags, hasLength(1));

      final restoredCard1 = restoredCards.firstWhere(
        (c) => c.front == 'Front 1',
      );
      expect(restoredCard1.state, equals(CardState.review.value));
      expect(restoredCard1.stability, closeTo(4.25, 0.001));
      expect(restoredCard1.difficulty, closeTo(6.1, 0.001));
      expect(restoredCard1.reps, equals(2));
      expect(restoredCard1.lapses, equals(1));

      final restoredCard2 = restoredCards.firstWhere(
        (c) => c.front.contains('{{c2::cloze}}'),
      );
      expect(restoredCard2.clozeIndex, equals(2));

      final card1Tags = await db.tagsDao.getTagsForCard(restoredCard1.id);
      expect(card1Tags, hasLength(1));
      expect(card1Tags.first.name, equals('Medicine'));

      final restoredLog = restoredLogs.first;
      expect(restoredLog.cardId, equals(restoredCard1.id));
      expect(restoredLog.rating, equals(Rating.good.value));
      expect(restoredLog.scheduledDays, equals(4));
    });

    test('Malformed JSON throws and rolls back transaction cleanly', () async {
      final deckId = await db.decksDao.createDeck(name: 'Initial Deck');
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Initial Front',
        back: 'Initial Back',
      );

      expect(await db.select(db.decks).get(), hasLength(1));

      // Attempt importing invalid JSON
      expect(
        () => backupService.importJsonPayload(
          '{"invalid json: missing closing brace',
        ),
        throwsA(isA<FormatException>()),
      );

      // Attempt importing JSON with missing required fields
      expect(
        () => backupService.importJsonPayload('{"version": 1}'),
        throwsA(isA<FormatException>()),
      );

      // Assert database remains untouched
      final decksAfter = await db.select(db.decks).get();
      expect(decksAfter, hasLength(1));
      expect(decksAfter.first.name, equals('Initial Deck'));
    });

    test(
      'CSV Export & Import handles multiline fields, commas, and quotes',
      () async {
        final deckId = await db.decksDao.createDeck(name: 'Literature');
        await db.cardsDao.createCard(
          deckId: deckId,
          front: 'Quote:\n"To be, or not to be"',
          back: 'Hamlet, by Shakespeare',
        );
        await db.cardsDao.createCard(
          deckId: deckId,
          front: 'Plain Front',
          back: 'Plain Back',
        );

        final csvOutput = await backupService.exportCardsToCsv(deckId: deckId);
        expect(csvOutput, startsWith('Front,Back,DeckName'));
        expect(csvOutput, contains('Hamlet, by Shakespeare'));

        final targetDeckId = await db.decksDao.createDeck(
          name: 'Import Target',
        );
        final result = await backupService.importCardsFromCsv(
          csvOutput,
          targetDeckId: targetDeckId,
        );

        expect(result.importedCount, equals(2));
        expect(result.skippedCount, equals(0));

        final importedCards = await db.cardsDao.getCardsByDeck(targetDeckId);
        expect(importedCards, hasLength(2));

        final quoteCard = importedCards.firstWhere(
          (c) => c.back == 'Hamlet, by Shakespeare',
        );
        expect(quoteCard.front, equals('Quote:\n"To be, or not to be"'));
      },
    );

    test('Malformed CSV skips empty and malformed rows gracefully', () async {
      final targetDeckId = await db.decksDao.createDeck(name: 'Target Deck');
      const malformedCsv = '''Front,Back
Valid Front 1,Valid Back 1
,Missing Front
Valid Front 2,
OnlyOneColumn
Valid Front 3,Valid Back 3''';

      final result = await backupService.importCardsFromCsv(
        malformedCsv,
        targetDeckId: targetDeckId,
      );

      expect(result.importedCount, equals(2)); // Rows 1 and 5
      expect(
        result.skippedCount,
        equals(3),
      ); // Empty front, empty back, one column

      final cards = await db.cardsDao.getCardsByDeck(targetDeckId);
      expect(cards, hasLength(2));
      expect(cards.any((c) => c.front == 'Valid Front 1'), isTrue);
      expect(cards.any((c) => c.front == 'Valid Front 3'), isTrue);
    });
  });
}
