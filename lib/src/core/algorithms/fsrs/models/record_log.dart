import 'card_state.dart';
import 'fsrs_card.dart';
import 'rating.dart';

class ReviewLogSnapshot {
  const ReviewLogSnapshot({
    required this.rating,
    required this.state,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.lastElapsedDays,
    required this.scheduledDays,
    required this.reviewedAt,
  });

  final Rating rating;
  final CardState state;
  final DateTime due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int lastElapsedDays;
  final int scheduledDays;
  final DateTime reviewedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewLogSnapshot &&
          runtimeType == other.runtimeType &&
          rating == other.rating &&
          state == other.state &&
          due == other.due &&
          stability == other.stability &&
          difficulty == other.difficulty &&
          elapsedDays == other.elapsedDays &&
          lastElapsedDays == other.lastElapsedDays &&
          scheduledDays == other.scheduledDays &&
          reviewedAt == other.reviewedAt;

  @override
  int get hashCode => Object.hash(
    rating,
    state,
    due,
    stability,
    difficulty,
    elapsedDays,
    lastElapsedDays,
    scheduledDays,
    reviewedAt,
  );
}

class RecordLog {
  const RecordLog({required this.card, required this.log});

  final FsrsCard card;
  final ReviewLogSnapshot log;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordLog &&
          runtimeType == other.runtimeType &&
          card == other.card &&
          log == other.log;

  @override
  int get hashCode => Object.hash(card, log);
}
