import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/fsrs_engine.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_card.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_models.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/fsrs_parameters.dart';

void main() {
  group('FSRS Fuzz Factor Tests', () {
    test('calculateFuzzOffset returns 0 for intervals under 3 days', () {
      final engine = FsrsEngine(const FsrsParameters(enableFuzz: true));
      expect(engine.calculateFuzzOffset(1), equals(0));
      expect(engine.calculateFuzzOffset(2), equals(0));
    });

    test('calculateFuzzOffset returns 0 when enableFuzz is false', () {
      final engine = FsrsEngine(const FsrsParameters(enableFuzz: false));
      expect(engine.calculateFuzzOffset(10), equals(0));
      expect(engine.calculateFuzzOffset(100), equals(0));
    });

    test('calculateFuzzOffset with seeded RNG is deterministic and bounded', () {
      // 5% of 100 days is maxOffset = 5. Range is [-5, +5].
      final rng = Random(42);
      final engine = FsrsEngine(const FsrsParameters(enableFuzz: true), rng);
      final offset = engine.calculateFuzzOffset(100);

      expect(offset.abs(), lessThanOrEqualTo(5));
      expect(offset, isNot(equals(0)));
    });

    test('repeat method returns deterministic intervals without fuzz for button previews', () {
      final engine = FsrsEngine(const FsrsParameters(enableFuzz: true));
      final card = FsrsCard(
        state: CardState.review,
        stability: 20.0,
        difficulty: 5.0,
        due: DateTime.utc(2026, 1, 1),
        lastReview: DateTime.utc(2025, 12, 10),
        reps: 4,
        lapses: 0,
      );

      final now = DateTime.utc(2026, 1, 1);
      final preview1 = engine.repeat(card, now);
      final preview2 = engine.repeat(card, now);

      // Previews must match exactly
      expect(preview1[Rating.good]?.log.scheduledDays, equals(preview2[Rating.good]?.log.scheduledDays));
      expect(preview1[Rating.easy]?.log.scheduledDays, equals(preview2[Rating.easy]?.log.scheduledDays));
    });
  });
}
