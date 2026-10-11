import '../../../core/algorithms/cloze/cloze_parser.dart';
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
    this.isSuspended = false,
    this.buriedUntil,
    this.clozeIndex,
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
  final bool isSuspended;
  final DateTime? buriedUntil;
  final int? clozeIndex;

  bool get isCloze => ClozeParser.isCloze(front);

  int get activeClozeIndex =>
      clozeIndex ?? (ClozeParser.extractClozeIndices(front).firstOrNull ?? 1);

  bool isBuried(DateTime now) {
    if (buriedUntil == null) return false;
    return buriedUntil!.isAfter(now.toUtc());
  }

  CardEntity copyWith({
    int? id,
    int? deckId,
    String? front,
    String? back,
    int? state,
    double? stability,
    double? difficulty,
    DateTime? due,
    DateTime? lastReview,
    int? reps,
    int? lapses,
    DateTime? createdAt,
    bool? isSuspended,
    DateTime? buriedUntil,
    int? clozeIndex,
  }) {
    return CardEntity(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      state: state ?? this.state,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      lastReview: lastReview ?? this.lastReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      createdAt: createdAt ?? this.createdAt,
      isSuspended: isSuspended ?? this.isSuspended,
      buriedUntil: buriedUntil ?? this.buriedUntil,
      clozeIndex: clozeIndex ?? this.clozeIndex,
    );
  }

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
          createdAt == other.createdAt &&
          isSuspended == other.isSuspended &&
          buriedUntil == other.buriedUntil &&
          clozeIndex == other.clozeIndex;

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
    isSuspended,
    buriedUntil,
    clozeIndex,
  );
}
