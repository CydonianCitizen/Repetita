import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/stats/presentation/stats_screen.dart';
import 'package:repetita/src/features/stats/presentation/widgets/review_heatmap_widget.dart';

void main() {
  late AppDatabase db;
  late int testDeckId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    testDeckId = await db.decksDao.createDeck(name: 'Stats Test Deck');
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildSubject({int? deckId, String? deckName}) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        home: StatsScreen(deckId: deckId, deckName: deckName),
      ),
    );
  }

  group('StatsScreen Widget Tests', () {
    testWidgets('renders empty metrics gracefully', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildSubject());
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('Retention'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('0 total'), findsOneWidget);
      expect(find.byType(ReviewHeatmapWidget), findsOneWidget);
      expect(find.text('Review Heatmap'), findsOneWidget);
      expect(find.text('Card State Breakdown'), findsOneWidget);
      expect(find.text('7-Day Review Forecast'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('renders populated metrics accurately', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final now = DateTime.now().toUtc();

      // Create cards in different states
      await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Card 1',
        back: 'A',
      );
      final c2 = await db.cardsDao.createCard(
        deckId: testDeckId,
        front: 'Card 2',
        back: 'A',
      );
      await (db.update(db.cards)..where((t) => t.id.equals(c2))).write(
        const CardsCompanion(state: drift.Value(2)), // Review
      );

      // Create 3 reviews: 2 Good (rating 3), 1 Again (rating 1) -> 2/3 = 67%
      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: c2,
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
      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: c2,
              rating: 3,
              state: 1,
              due: now,
              stability: 3.0,
              difficulty: 5.0,
              elapsedDays: 1,
              lastElapsedDays: 1,
              scheduledDays: 3,
              reviewedAt: now,
            ),
          );
      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: c2,
              rating: 1,
              state: 2,
              due: now,
              stability: 0.5,
              difficulty: 5.0,
              elapsedDays: 2,
              lastElapsedDays: 1,
              scheduledDays: 1,
              reviewedAt: now,
            ),
          );

      await tester.pumpWidget(
        buildSubject(deckId: testDeckId, deckName: 'Biology'),
      );
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Biology Stats'), findsOneWidget);
      expect(find.text('67%'), findsOneWidget);
      expect(find.text('Retention'), findsOneWidget);
      expect(find.text('3'), findsWidgets); // 3 reviews
      expect(find.text('Reviews'), findsOneWidget);
      expect(find.text('2 total'), findsOneWidget); // 2 cards
      expect(find.byType(ReviewHeatmapWidget), findsOneWidget);
      expect(find.text('Review Heatmap'), findsOneWidget);
      expect(find.text('1 day'), findsOneWidget);
      expect(find.text('7-Day Review Forecast'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
