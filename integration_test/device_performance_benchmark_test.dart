import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:repetita/src/core/algorithms/fsrs/fsrs_engine.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_card.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_models.dart';
import 'package:repetita/src/core/algorithms/sm2/sm2_engine.dart';
import 'package:repetita/src/core/database/app_database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ARM64 Hardware Performance Benchmark', () {
    test('FSRS v4.5 Math Engine Throughput (20,000 calculations)', () {
      const engine = FsrsEngine();
      final now = DateTime.utc(2026, 10, 15, 12, 0, 0);

      var card = FsrsCard(due: now);
      final ratings = [
        Rating.good,
        Rating.hard,
        Rating.good,
        Rating.easy,
        Rating.again,
        Rating.good,
      ];

      final stopwatch = Stopwatch()..start();
      const iterations = 20000;

      for (var i = 0; i < iterations; i++) {
        final rating = ratings[i % ratings.length];
        final record = engine.schedule(
          card,
          rating,
          now.add(Duration(days: i)),
        );
        card = record.card;
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      final totalMicros = stopwatch.elapsedMicroseconds;
      final opsPerSec = (iterations / (totalMicros / 1000000)).round();
      final latencyPerOpMicros = (totalMicros / iterations).toStringAsFixed(2);

      // ignore: avoid_print
      print('\n>>> BENCHMARK: FSRS v4.5 ENGINE <<<');
      // ignore: avoid_print
      print('Iterations: $iterations');
      // ignore: avoid_print
      print('Total Time: ${totalMs}ms ($totalMicros µs)');
      // ignore: avoid_print
      print('Throughput: $opsPerSec ops/sec');
      // ignore: avoid_print
      print('Mean Latency: $latencyPerOpMicros µs/op');

      expect(totalMs, lessThan(2000));
    });

    test('SM-2 Algorithm Engine Throughput (20,000 calculations)', () {
      const engine = Sm2Engine();
      final now = DateTime.utc(2026, 10, 15, 12, 0, 0);

      var card = FsrsCard(due: now);
      final ratings = [
        Rating.good,
        Rating.hard,
        Rating.good,
        Rating.easy,
        Rating.again,
        Rating.good,
      ];

      final stopwatch = Stopwatch()..start();
      const iterations = 20000;

      for (var i = 0; i < iterations; i++) {
        final rating = ratings[i % ratings.length];
        final record = engine.schedule(
          card,
          rating,
          now.add(Duration(days: i)),
        );
        card = record.card;
      }
      stopwatch.stop();

      final totalMs = stopwatch.elapsedMilliseconds;
      final totalMicros = stopwatch.elapsedMicroseconds;
      final opsPerSec = (iterations / (totalMicros / 1000000)).round();
      final latencyPerOpMicros = (totalMicros / iterations).toStringAsFixed(2);

      // ignore: avoid_print
      print('\n>>> BENCHMARK: SM-2 ENGINE <<<');
      // ignore: avoid_print
      print('Iterations: $iterations');
      // ignore: avoid_print
      print('Total Time: ${totalMs}ms ($totalMicros µs)');
      // ignore: avoid_print
      print('Throughput: $opsPerSec ops/sec');
      // ignore: avoid_print
      print('Mean Latency: $latencyPerOpMicros µs/op');

      expect(totalMs, lessThan(2000));
    });

    test('SQLite / Drift Storage Throughput (1,000 batch insert & query)', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final now = DateTime.utc(2026, 10, 15, 12, 0, 0);

      // 1. Create a Deck
      final deckId = await db.decksDao.createDeck(
        name: 'Benchmark Deck',
        now: now,
      );

      // 2. Measure Batch Insert of 1,000 cards in single transaction
      final companions = List.generate(
        1000,
        (i) => CardsCompanion.insert(
          deckId: deckId,
          front: 'Question $i: What is the complexity of algorithm $i?',
          back: 'Answer $i: O(1)',
          due: now.add(Duration(days: i % 10)),
          createdAt: drift.Value(now),
        ),
      );

      final insertSw = Stopwatch()..start();
      await db.batch((b) {
        b.insertAll(db.cards, companions);
      });
      insertSw.stop();

      final insertMs = insertSw.elapsedMilliseconds;
      final insertOpsPerSec = (1000 / (insertSw.elapsedMicroseconds / 1000000))
          .round();

      // 3. Measure Query of 1,000 cards
      final querySw = Stopwatch()..start();
      final cards = await db.cardsDao.getCardsByDeck(deckId);
      querySw.stop();

      final queryMs = querySw.elapsedMilliseconds;

      // 4. Measure Decks With Counts calculation (join + aggregations)
      final countSw = Stopwatch()..start();
      final decksWithCounts = await db.decksDao.watchAllDecksWithCounts().first;
      countSw.stop();

      final countMs = countSw.elapsedMilliseconds;

      // ignore: avoid_print
      print('\n>>> BENCHMARK: DRIFT SQLITE PERSISTENCE <<<');
      // ignore: avoid_print
      print(
        'Batch Insert (1,000 rows): ${insertMs}ms ($insertOpsPerSec rows/sec)',
      );
      // ignore: avoid_print
      print('Query (1,000 rows): ${queryMs}ms (${cards.length} rows)');
      // ignore: avoid_print
      print(
        'Aggregated Join & Counts Query: ${countMs}ms (Total: ${decksWithCounts.first.totalCards})',
      );

      await db.close();

      expect(cards.length, equals(1000));
      expect(decksWithCounts.first.totalCards, equals(1000));
    });
  });
}
