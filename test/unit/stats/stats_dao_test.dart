import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/stats/data/stats_dao.dart';
import 'package:repetita/src/features/stats/domain/stats_models.dart';

void main() {
  late AppDatabase db;
  late StatsDao statsDao;
  late int deck1Id;
  late int deck2Id;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    statsDao = db.statsDao;

    deck1Id = await db.decksDao.createDeck(name: 'Deck 1');
    deck2Id = await db.decksDao.createDeck(name: 'Deck 2');
  });

  tearDown(() async {
    await db.close();
  });

  group('StatsDao Unit Tests', () {
    test(
      'getCardStateCounts returns accurate counts globally and per deck',
      () async {
        // Deck 1: 1 New, 1 Learning, 1 Review
        await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'D1 New',
          back: 'A',
        );
        final c2 = await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'D1 Learn',
          back: 'A',
        );
        await (db.update(db.cards)..where((t) => t.id.equals(c2))).write(
          const CardsCompanion(state: drift.Value(1)),
        );
        final c3 = await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'D1 Rev',
          back: 'A',
        );
        await (db.update(db.cards)..where((t) => t.id.equals(c3))).write(
          const CardsCompanion(state: drift.Value(2)),
        );

        // Deck 2: 1 Relearning
        final c4 = await db.cardsDao.createCard(
          deckId: deck2Id,
          front: 'D2 Relearn',
          back: 'A',
        );
        await (db.update(db.cards)..where((t) => t.id.equals(c4))).write(
          const CardsCompanion(state: drift.Value(3)),
        );

        // Deck 1 counts
        final deck1Counts = await statsDao.getCardStateCounts(deckId: deck1Id);
        expect(deck1Counts.newCount, equals(1));
        expect(deck1Counts.learningCount, equals(1));
        expect(deck1Counts.reviewCount, equals(1));
        expect(deck1Counts.relearningCount, equals(0));
        expect(deck1Counts.total, equals(3));

        // Global counts
        final globalCounts = await statsDao.getCardStateCounts();
        expect(globalCounts.newCount, equals(1));
        expect(globalCounts.learningCount, equals(1));
        expect(globalCounts.reviewCount, equals(1));
        expect(globalCounts.relearningCount, equals(1));
        expect(globalCounts.total, equals(4));
      },
    );

    test(
      'getRetentionRate calculates percentage of successful ratings (>= 2)',
      () async {
        final now = DateTime.now().toUtc();

        // Empty logs check
        final emptyRate = await statsDao.getRetentionRate();
        expect(emptyRate, equals(0.0));

        final card1 = await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'Q1',
          back: 'A1',
        );
        final card2 = await db.cardsDao.createCard(
          deckId: deck2Id,
          front: 'Q2',
          back: 'A2',
        );

        // Add reviews for deck 1: 3 Good (rating 3), 1 Again (rating 1) -> 3/4 = 0.75
        for (int i = 0; i < 3; i++) {
          await db
              .into(db.reviewLogs)
              .insert(
                ReviewLogsCompanion.insert(
                  cardId: card1,
                  rating: 3, // Good (>= 2)
                  state: 0,
                  due: now,
                  stability: 2.0,
                  difficulty: 5.0,
                  elapsedDays: 0,
                  lastElapsedDays: 0,
                  scheduledDays: 1,
                  reviewedAt: now,
                ),
              );
        }
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: card1,
                rating: 1, // Again (< 2)
                state: 1,
                due: now,
                stability: 0.5,
                difficulty: 5.0,
                elapsedDays: 1,
                lastElapsedDays: 1,
                scheduledDays: 1,
                reviewedAt: now,
              ),
            );

        // Add review for deck 2: 1 Easy (rating 4) -> 1/1 = 1.0
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: card2,
                rating: 4, // Easy (>= 2)
                state: 0,
                due: now,
                stability: 5.0,
                difficulty: 4.0,
                elapsedDays: 0,
                lastElapsedDays: 0,
                scheduledDays: 4,
                reviewedAt: now,
              ),
            );

        // Deck 1 retention
        final deck1Rate = await statsDao.getRetentionRate(deckId: deck1Id);
        expect(deck1Rate, closeTo(0.75, 0.001));

        // Deck 2 retention
        final deck2Rate = await statsDao.getRetentionRate(deckId: deck2Id);
        expect(deck2Rate, closeTo(1.0, 0.001));

        // Global retention: 4 successful out of 5 total = 0.8
        final globalRate = await statsDao.getRetentionRate();
        expect(globalRate, closeTo(0.8, 0.001));
      },
    );

    test('getTotalReviewsCount returns total logs count', () async {
      final now = DateTime.now().toUtc();
      final card1 = await db.cardsDao.createCard(
        deckId: deck1Id,
        front: 'Q1',
        back: 'A1',
      );

      expect(await statsDao.getTotalReviewsCount(), equals(0));

      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: card1,
              rating: 3,
              state: 0,
              due: now,
              stability: 2.0,
              difficulty: 5.0,
              elapsedDays: 0,
              lastElapsedDays: 0,
              scheduledDays: 1,
              reviewedAt: now,
            ),
          );

      expect(await statsDao.getTotalReviewsCount(deckId: deck1Id), equals(1));
      expect(await statsDao.getTotalReviewsCount(deckId: deck2Id), equals(0));
      expect(await statsDao.getTotalReviewsCount(), equals(1));
    });

    test('getDueForecast projects cards across 7 days', () async {
      final now = DateTime.utc(2026, 10, 11, 10, 0);

      // Day 0: 1 new card + 1 overdue card
      await db.cardsDao.createCard(
        deckId: deck1Id,
        front: 'New Card',
        back: 'A',
      );
      final cOverdue = await db.cardsDao.createCard(
        deckId: deck1Id,
        front: 'Overdue',
        back: 'A',
      );
      await (db.update(db.cards)..where((t) => t.id.equals(cOverdue))).write(
        CardsCompanion(
          state: const drift.Value(2),
          due: drift.Value(now.subtract(const Duration(days: 1))),
        ),
      );

      // Day 1: 1 review card
      final cDay1 = await db.cardsDao.createCard(
        deckId: deck1Id,
        front: 'Day 1 Card',
        back: 'A',
      );
      await (db.update(db.cards)..where((t) => t.id.equals(cDay1))).write(
        CardsCompanion(
          state: const drift.Value(2),
          due: drift.Value(DateTime.utc(2026, 10, 12, 12, 0)),
        ),
      );

      // Day 3: 2 review cards
      for (int i = 0; i < 2; i++) {
        final cDay3 = await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'Day 3 Card $i',
          back: 'A',
        );
        await (db.update(db.cards)..where((t) => t.id.equals(cDay3))).write(
          CardsCompanion(
            state: const drift.Value(2),
            due: drift.Value(DateTime.utc(2026, 10, 14, 15, 0)),
          ),
        );
      }

      final forecast = await statsDao.getDueForecast(
        deckId: deck1Id,
        days: 7,
        fromDate: now,
      );

      expect(forecast, hasLength(7));
      expect(forecast[0].count, equals(2)); // Day 0 (today): New + Overdue
      expect(forecast[1].count, equals(1)); // Day 1
      expect(forecast[2].count, equals(0)); // Day 2
      expect(forecast[3].count, equals(2)); // Day 3
      expect(forecast[4].count, equals(0)); // Day 4
      expect(forecast[5].count, equals(0)); // Day 5
      expect(forecast[6].count, equals(0)); // Day 6
    });

    test('calculateStreak computes consecutive streak correctly', () {
      final today = DateTime.utc(2026, 10, 11);

      // Empty review dates
      expect(calculateStreak({}, today), equals(0));

      // Reviewed today only -> 1 day streak
      expect(calculateStreak({today}, today), equals(1));

      // Reviewed yesterday only -> 1 day streak (active habit)
      expect(
        calculateStreak({today.subtract(const Duration(days: 1))}, today),
        equals(1),
      );

      // Reviewed 2 days ago but not yesterday -> 0 streak
      expect(
        calculateStreak({today.subtract(const Duration(days: 2))}, today),
        equals(0),
      );

      // 4 consecutive days including today -> 4 days streak
      final fourDays = {
        today,
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 2)),
        today.subtract(const Duration(days: 3)),
      };
      expect(calculateStreak(fourDays, today), equals(4));

      // 3 consecutive days ending yesterday (has not studied today yet) -> 3 days streak
      final threeDaysEndingYesterday = {
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 2)),
        today.subtract(const Duration(days: 3)),
      };
      expect(calculateStreak(threeDaysEndingYesterday, today), equals(3));
    });

    test(
      'getDailyReviewCounts and getCurrentStreak query database correctly',
      () async {
        final today = DateTime.utc(2026, 10, 11, 14, 0);
        final cardId = await db.cardsDao.createCard(
          deckId: deck1Id,
          front: 'Streak Card',
          back: 'A',
        );

        // Add 2 reviews today
        for (int i = 0; i < 2; i++) {
          await db
              .into(db.reviewLogs)
              .insert(
                ReviewLogsCompanion.insert(
                  cardId: cardId,
                  rating: 3,
                  state: 1,
                  due: today,
                  stability: 2.0,
                  difficulty: 5.0,
                  elapsedDays: 0,
                  lastElapsedDays: 0,
                  scheduledDays: 1,
                  reviewedAt: today.add(Duration(minutes: i * 30)),
                ),
              );
        }

        // Add 1 review yesterday
        final yesterday = today.subtract(const Duration(days: 1));
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: cardId,
                rating: 3,
                state: 1,
                due: yesterday,
                stability: 2.0,
                difficulty: 5.0,
                elapsedDays: 0,
                lastElapsedDays: 0,
                scheduledDays: 1,
                reviewedAt: yesterday,
              ),
            );

        // Daily review counts
        final counts = await statsDao.getDailyReviewCounts(
          deckId: deck1Id,
          days: 7,
          toDate: today,
        );

        final todayKey = DateTime.utc(2026, 10, 11);
        final yesterdayKey = DateTime.utc(2026, 10, 10);

        expect(counts[todayKey], equals(2));
        expect(counts[yesterdayKey], equals(1));

        // Current streak
        final streak = await statsDao.getCurrentStreak(
          deckId: deck1Id,
          today: today,
        );
        expect(streak, equals(2));
      },
    );
  });
}
