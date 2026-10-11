import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/card_state.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_card.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/rating.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/record_log.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/study_session/data/study_session_dao.dart';

void main() {
  late AppDatabase db;
  late StudySessionDao studySessionDao;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    studySessionDao = db.studySessionDao;
    testDeckId = await db.decksDao.createDeck(name: 'Study Deck');
  });

  tearDown(() async {
    await db.close();
  });

  group('StudySessionDao Unit Tests', () {
    test('fetchDueCards returns cards due before cutoff or in state 0 ordered by due ASC, id ASC', () async {
      final now = DateTime.now().toUtc();

      // Card 1: New card
      final card1Id = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Card 1 (New)',
        back: 'Ans 1',
      );

      // Card 2: Overdue card (created, then updated to review state with past due)
      final card2Id = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Card 2 (Overdue)',
        back: 'Ans 2',
      );
      final pastDue = now.subtract(const Duration(days: 2));
      await studySessionDao.recordReview(
        cardId: card2Id,
        updatedCard: FsrsCard(
          state: CardState.review,
          stability: 2.5,
          difficulty: 5.0,
          due: pastDue,
          lastReview: pastDue,
          reps: 1,
          lapses: 0,
        ),
        logSnapshot: ReviewLogSnapshot(
          rating: Rating.good,
          state: CardState.newCard,
          due: pastDue,
          stability: 2.5,
          difficulty: 5.0,
          elapsedDays: 0,
          lastElapsedDays: 0,
          scheduledDays: 1,
          reviewedAt: pastDue,
        ),
      );

      // Card 3: Future card (due in 5 days, review state)
      final card3Id = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Card 3 (Future)',
        back: 'Ans 3',
      );
      final futureDue = now.add(const Duration(days: 5));
      await studySessionDao.recordReview(
        cardId: card3Id,
        updatedCard: FsrsCard(
          state: CardState.review,
          stability: 5.0,
          difficulty: 5.0,
          due: futureDue,
          lastReview: now,
          reps: 1,
          lapses: 0,
        ),
        logSnapshot: ReviewLogSnapshot(
          rating: Rating.good,
          state: CardState.newCard,
          due: futureDue,
          stability: 5.0,
          difficulty: 5.0,
          elapsedDays: 0,
          lastElapsedDays: 0,
          scheduledDays: 5,
          reviewedAt: now,
        ),
      );

      final dueCards = await studySessionDao.fetchDueCards(
        testDeckId,
        cutoff: now,
      );

      expect(dueCards, hasLength(2));
      // Card 2 is due first (past due), then Card 1 (New)
      expect(dueCards[0].id, equals(card2Id));
      expect(dueCards[1].id, equals(card1Id));
    });

    test(
      'recordReview atomic transaction updates Cards and inserts ReviewLog',
      () async {
        final now = DateTime.now().toUtc();
        final cardId = await db.cardsDao.createCard(
          deckId: testDeckId,
          front: 'Test Front',
          back: 'Test Back',
        );

        final nextDue = now.add(const Duration(days: 3));
        final updatedCard = FsrsCard(
          state: CardState.review,
          stability: 3.14,
          difficulty: 4.8,
          due: nextDue,
          lastReview: now,
          reps: 1,
          lapses: 0,
        );

        final logSnapshot = ReviewLogSnapshot(
          rating: Rating.good,
          state: CardState.newCard,
          due: now,
          stability: 3.14,
          difficulty: 4.8,
          elapsedDays: 0,
          lastElapsedDays: 0,
          scheduledDays: 3,
          reviewedAt: now,
        );

        await studySessionDao.recordReview(
          cardId: cardId,
          updatedCard: updatedCard,
          logSnapshot: logSnapshot,
        );

        // Verify Cards table row updated
        final cardInDb = await (db.select(
          db.cards,
        )..where((t) => t.id.equals(cardId))).getSingle();
        expect(cardInDb.state, equals(CardState.review.value));
        expect(cardInDb.stability, closeTo(3.14, 0.001));
        expect(cardInDb.difficulty, closeTo(4.8, 0.001));
        expect(
          cardInDb.due.difference(nextDue).inSeconds.abs(),
          lessThanOrEqualTo(2),
        );
        expect(
          cardInDb.lastReview?.difference(now).inSeconds.abs(),
          lessThanOrEqualTo(2),
        );
        expect(cardInDb.reps, equals(1));
        expect(cardInDb.lapses, equals(0));

        // Verify ReviewLogs table row inserted
        final logs = await (db.select(
          db.reviewLogs,
        )..where((t) => t.cardId.equals(cardId))).get();
        expect(logs, hasLength(1));
        final log = logs.first;
        expect(log.cardId, equals(cardId));
        expect(log.rating, equals(Rating.good.value));
        expect(log.state, equals(CardState.newCard.value));
        expect(log.stability, closeTo(3.14, 0.001));
        expect(log.difficulty, closeTo(4.8, 0.001));
        expect(log.scheduledDays, equals(3));
        expect(
          log.reviewedAt.difference(now).inSeconds.abs(),
          lessThanOrEqualTo(2),
        );
      },
    );

    test('transaction rolls back completely if an error occurs', () async {
      final now = DateTime.now().toUtc();
      final cardId = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Rollback Front',
        back: 'Rollback Back',
      );

      // Attempt transaction that throws midway
      try {
        await db.transaction(() async {
          // Update card
          await studySessionDao.recordReview(
            cardId: cardId,
            updatedCard: FsrsCard(
              state: CardState.review,
              stability: 9.9,
              difficulty: 1.1,
              due: now.add(const Duration(days: 10)),
              lastReview: now,
              reps: 5,
              lapses: 0,
            ),
            logSnapshot: ReviewLogSnapshot(
              rating: Rating.easy,
              state: CardState.newCard,
              due: now,
              stability: 9.9,
              difficulty: 1.1,
              elapsedDays: 0,
              lastElapsedDays: 0,
              scheduledDays: 10,
              reviewedAt: now,
            ),
          );

          // Simulate subsequent failure
          throw Exception('Forced failure to trigger rollback');
        });
      } catch (_) {
        // Exception caught as expected
      }

      // Assert Cards table was NOT updated
      final cardInDb = await (db.select(
        db.cards,
      )..where((t) => t.id.equals(cardId))).getSingle();
      expect(cardInDb.state, equals(CardState.newCard.value));
      expect(cardInDb.stability, equals(0.0));
      expect(cardInDb.reps, equals(0));

      // Assert ReviewLogs has NO entries
      final logs = await (db.select(
        db.reviewLogs,
      )..where((t) => t.cardId.equals(cardId))).get();
      expect(logs, isEmpty);
    });
  });
}
