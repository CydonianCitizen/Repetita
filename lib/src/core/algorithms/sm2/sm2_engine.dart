import 'dart:math' as math;

import '../fsrs/models/fsrs_card.dart';
import '../fsrs/models/fsrs_models.dart';
import '../fsrs/models/record_log.dart';
import '../srs/srs_scheduler.dart';

/// Pure Dart implementation of the classic SuperMemo SM-2 algorithm.
///
/// Implements [SrsScheduler] so it can be swapped seamlessly with [FsrsEngine]
/// via the Strategy pattern.
class Sm2Engine implements SrsScheduler {
  const Sm2Engine({
    this.initialEasinessFactor = 2.5,
    this.minEasinessFactor = 1.3,
  });

  final double initialEasinessFactor;
  final double minEasinessFactor;

  @override
  RecordLog schedule(FsrsCard card, Rating rating, DateTime reviewTime) {
    final q = _ratingToQuality(rating);
    final currentEf = _resolveCurrentEf(card);

    // Calculate new Easiness Factor (EF)
    // Formula: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
    final delta = 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
    final nextEf = math.max(minEasinessFactor, currentEf + delta);

    final CardState nextState;
    final int nextReps;
    final int nextLapses;
    final int intervalDays;

    if (rating == Rating.again) {
      nextState = card.state == CardState.newCard
          ? CardState.learning
          : CardState.relearning;
      nextReps = 0;
      nextLapses = card.lapses + 1;
      intervalDays = 1;
    } else {
      nextState = CardState.review;
      nextReps = card.reps + 1;
      nextLapses = card.lapses;

      if (nextReps == 1) {
        intervalDays = rating == Rating.easy ? 4 : 1;
      } else if (nextReps == 2) {
        if (rating == Rating.hard) {
          intervalDays = 4;
        } else if (rating == Rating.easy) {
          intervalDays = 8;
        } else {
          intervalDays = 6;
        }
      } else {
        final elapsed = card.lastReview != null
            ? reviewTime.difference(card.lastReview!).inDays
            : 6;
        final baseInterval = elapsed > 0 ? elapsed : 6;

        if (rating == Rating.hard) {
          final computed = (baseInterval * 1.2).round();
          intervalDays = computed > baseInterval ? computed : baseInterval + 1;
        } else if (rating == Rating.good) {
          final computed = (baseInterval * nextEf).round();
          intervalDays = computed > baseInterval ? computed : baseInterval + 1;
        } else {
          // Easy bonus: 1.3x on top of EF
          final computed = (baseInterval * nextEf * 1.3).round();
          intervalDays = computed > baseInterval ? computed : baseInterval + 2;
        }
      }
    }

    final nextDue = reviewTime.add(Duration(days: intervalDays));
    final elapsedDays = card.lastReview != null
        ? reviewTime.difference(card.lastReview!).inDays
        : 0;

    // Map EF to FSRS difficulty [1.0, 10.0] for cross-engine compatibility
    final mappedDifficulty = (1.0 + (2.5 - nextEf) * (9.0 / 1.2)).clamp(
      1.0,
      10.0,
    );

    final updatedCard = FsrsCard(
      state: nextState,
      stability: intervalDays.toDouble(),
      difficulty: mappedDifficulty,
      due: nextDue,
      lastReview: reviewTime,
      reps: nextReps,
      lapses: nextLapses,
      easinessFactor: nextEf,
    );

    final log = ReviewLogSnapshot(
      rating: rating,
      state: card.state,
      due: nextDue,
      stability: intervalDays.toDouble(),
      difficulty: mappedDifficulty,
      elapsedDays: elapsedDays,
      lastElapsedDays: 0,
      scheduledDays: intervalDays,
      reviewedAt: reviewTime,
      easinessFactor: nextEf,
    );

    return RecordLog(card: updatedCard, log: log);
  }

  @override
  Map<Rating, RecordLog> repeat(FsrsCard card, DateTime reviewTime) {
    return {
      Rating.again: schedule(card, Rating.again, reviewTime),
      Rating.hard: schedule(card, Rating.hard, reviewTime),
      Rating.good: schedule(card, Rating.good, reviewTime),
      Rating.easy: schedule(card, Rating.easy, reviewTime),
    };
  }

  int _ratingToQuality(Rating rating) {
    return switch (rating) {
      Rating.again => 1,
      Rating.hard => 3,
      Rating.good => 4,
      Rating.easy => 5,
    };
  }

  double _resolveCurrentEf(FsrsCard card) {
    if (card.easinessFactor > 0) {
      return card.easinessFactor;
    }
    // Transition rule: derive initial EF from FSRS difficulty if present
    if (card.difficulty > 0) {
      final derived = 2.5 - (card.difficulty - 1.0) * (1.2 / 9.0);
      return derived.clamp(minEasinessFactor, 3.0);
    }
    return initialEasinessFactor;
  }
}
