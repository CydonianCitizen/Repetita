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
    this.easinessFactor = 2.5,
  });

  final CardState state;
  final double stability;
  final double difficulty;
  final DateTime due;
  final DateTime? lastReview;
  final int reps;
  final int lapses;
  final double easinessFactor;

  FsrsCard copyWith({
    CardState? state,
    double? stability,
    double? difficulty,
    DateTime? due,
    DateTime? lastReview,
    int? reps,
    int? lapses,
    double? easinessFactor,
  }) {
    return FsrsCard(
      state: state ?? this.state,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      lastReview: lastReview ?? this.lastReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      easinessFactor: easinessFactor ?? this.easinessFactor,
    );
  }

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
          lapses == other.lapses &&
          easinessFactor == other.easinessFactor;

  @override
  int get hashCode => Object.hash(
    state,
    stability,
    difficulty,
    due,
    lastReview,
    reps,
    lapses,
    easinessFactor,
  );
}
