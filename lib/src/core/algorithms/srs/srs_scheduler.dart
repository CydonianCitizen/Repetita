import '../fsrs/models/fsrs_card.dart';
import '../fsrs/models/fsrs_models.dart';
import '../fsrs/models/record_log.dart';

/// Common contract for Spaced Repetition Scheduling engines (FSRS, SM-2, etc.).
abstract interface class SrsScheduler {
  /// Schedules next review for [card] given user [rating] at [reviewTime].
  RecordLog schedule(FsrsCard card, Rating rating, DateTime reviewTime);

  /// Computes simulated schedule outcomes for all standard ratings.
  Map<Rating, RecordLog> repeat(FsrsCard card, DateTime reviewTime);
}
