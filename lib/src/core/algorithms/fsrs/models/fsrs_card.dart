import 'fsrs_models.dart';

class FsrsCard {
  const FsrsCard({
    this.state = CardState.newCard,
    this.stability = 0.0,
    this.difficulty = 0.0,
    required this.due,
    this.lastReview,
    this.reps = 0,
    this.lapses = 0,
  });

  final CardState state;
  final double stability;
  final double difficulty;
  final DateTime due;
  final DateTime? lastReview;
  final int reps;
  final int lapses;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsrsCard &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          stability == other.stability &&
          difficulty == other.difficulty &&
          due == other.due &&
          lastReview == other.lastReview &&
          reps == other.reps &&
          lapses == other.lapses;

  @override
  int get hashCode =>
      Object.hash(state, stability, difficulty, due, lastReview, reps, lapses);
}
