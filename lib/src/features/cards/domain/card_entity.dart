import '../../../core/algorithms/fsrs/models/card_state.dart';
import '../../../core/algorithms/fsrs/models/fsrs_card.dart';

class CardEntity {
  const CardEntity({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.state,
    required this.stability,
    required this.difficulty,
    required this.due,
    this.lastReview,
    required this.reps,
    required this.lapses,
    required this.createdAt,
  });

  final int id;
  final int deckId;
  final String front;
  final String back;
  final int state;
  final double stability;
  final double difficulty;
  final DateTime due;
  final DateTime? lastReview;
  final int reps;
  final int lapses;
  final DateTime createdAt;

  FsrsCard toFsrsCard() => FsrsCard(
    state: CardState.values.firstWhere(
      (s) => s.value == state,
      orElse: () => CardState.newCard,
    ),
    stability: stability,
    difficulty: difficulty,
    due: due,
    lastReview: lastReview,
    reps: reps,
    lapses: lapses,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deckId == other.deckId &&
          front == other.front &&
          back == other.back &&
          state == other.state &&
          stability == other.stability &&
          difficulty == other.difficulty &&
          due == other.due &&
          lastReview == other.lastReview &&
          reps == other.reps &&
          lapses == other.lapses &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    front,
    back,
    state,
    stability,
    difficulty,
    due,
    lastReview,
    reps,
    lapses,
    createdAt,
  );
}
