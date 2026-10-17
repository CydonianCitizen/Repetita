import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/features/decks/data/decks_dao.dart';
import 'package:repetita/src/features/decks/domain/exam_study_planner.dart';

void main() {
  group('ExamStudyPlanner Tests', () {
    final planner = const ExamStudyPlanner();

    test('calculates correct daily new cards quota when days remaining > 0', () {
      final now = DateTime(2026, 10, 1);
      final examDate = DateTime(2026, 10, 11); // 10 days remaining

      final result = planner.calculatePlan(
        now: now,
        examDate: examDate,
        newCardsCount: 100,
        reviewCardsCount: 50,
      );

      expect(result.daysRemaining, equals(10));
      expect(result.dailyNewCardsQuota, equals(10)); // 100 / 10 = 10
      expect(result.isUnsustainable, isFalse);
      expect(result.suggestedRetention, equals(0.90));
    });

    test('ceils daily new cards quota for uneven numbers', () {
      final now = DateTime(2026, 10, 1);
      final examDate = DateTime(2026, 10, 11); // 10 days remaining

      final result = planner.calculatePlan(
        now: now,
        examDate: examDate,
        newCardsCount: 105,
        reviewCardsCount: 20,
      );

      expect(result.daysRemaining, equals(10));
      expect(result.dailyNewCardsQuota, equals(11)); // ceil(105 / 10) = 11
    });

    test('handles 0 new cards gracefully', () {
      final now = DateTime(2026, 10, 1);
      final examDate = DateTime(2026, 10, 6);

      final result = planner.calculatePlan(
        now: now,
        examDate: examDate,
        newCardsCount: 0,
        reviewCardsCount: 30,
      );

      expect(result.daysRemaining, equals(5));
      expect(result.dailyNewCardsQuota, equals(0));
      expect(result.isUnsustainable, isFalse);
    });

    test('handles exam date in past or today (0 days remaining)', () {
      final now = DateTime(2026, 10, 5, 12, 0);
      final examDate = DateTime(2026, 10, 5, 8, 0);

      final result = planner.calculatePlan(
        now: now,
        examDate: examDate,
        newCardsCount: 25,
        reviewCardsCount: 10,
      );

      expect(result.daysRemaining, equals(0));
      expect(result.dailyNewCardsQuota, equals(25));
      expect(result.isUnsustainable, isTrue);
    });

    test('flags unsustainable backlog when workload exceeds max daily capacity', () {
      final now = DateTime(2026, 10, 1);
      final examDate = DateTime(2026, 10, 3); // 2 days remaining

      // 300 new cards in 2 days = 150 new cards/day, way above capacity
      final result = planner.calculatePlan(
        now: now,
        examDate: examDate,
        newCardsCount: 300,
        reviewCardsCount: 100,
      );

      expect(result.daysRemaining, equals(2));
      expect(result.dailyNewCardsQuota, equals(150));
      expect(result.isUnsustainable, isTrue);
    });

    test('preserves custom target retention when specified', () {
      final now = DateTime(2026, 10, 1);
      final examDate = DateTime(2026, 10, 20);

      final result = planner.calculatePlan(
        now: now,
        examDate: examDate,
        newCardsCount: 50,
        reviewCardsCount: 20,
        targetRetention: 0.85,
      );

      expect(result.suggestedRetention, equals(0.85));
    });
  });

  group('DecksDao Exam Date Tests', () {
    late AppDatabase db;
    late DecksDao dao;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dao = db.decksDao;
    });

    tearDown(() async {
      await db.close();
    });

    test('updates and clears deck exam date and target retention', () async {
      final deckId = await dao.createDeck(name: 'Biology 101');
      final examDate = DateTime.utc(2026, 12, 15);

      // Set exam date and retention
      final updated = await dao.setDeckExamDate(
        deckId: deckId,
        examDate: examDate,
        targetRetention: 0.92,
      );
      expect(updated, isTrue);

      final deck = await dao.getDeckById(deckId);
      expect(deck, isNotNull);
      expect(deck!.examDate!.isAtSameMomentAs(examDate), isTrue);
      expect(deck.targetRetention, equals(0.92));

      // Clear exam date
      final cleared = await dao.setDeckExamDate(
        deckId: deckId,
        examDate: null,
        targetRetention: null,
      );
      expect(cleared, isTrue);

      final clearedDeck = await dao.getDeckById(deckId);
      expect(clearedDeck!.examDate, isNull);
      expect(clearedDeck.targetRetention, isNull);
    });
  });
}
