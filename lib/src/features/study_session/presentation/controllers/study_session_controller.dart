import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/clock_provider.dart';

import '../../../../core/algorithms/fsrs/fsrs_engine.dart';
import '../../../../core/algorithms/fsrs/models/fsrs_models.dart';
import '../../../../core/database/app_database.dart' show Card;
import '../../../../core/database/database_provider.dart';
import '../../../cards/data/cards_dao.dart';
import '../../../cards/domain/card_entity.dart';
import '../../../settings/presentation/controllers/fsrs_parameters_controller.dart';
import '../../domain/models/custom_study_config.dart';

part 'study_session_controller.g.dart';

class StudySessionHistoryEntry {
  const StudySessionHistoryEntry({
    required this.card,
    required this.index,
    this.reviewLogId,
    this.requeued = false,
  });

  final CardEntity card;
  final int index;
  final int? reviewLogId;
  final bool requeued;
}

class StudySessionState {
  const StudySessionState({
    required this.deckId,
    this.queue = const [],
    this.currentIndex = 0,
    this.isAnswerRevealed = false,
    this.isCompleted = false,
    this.undoStack = const [],
    this.isCram = false,
    this.customStudyConfig,
    this.intervalPreviews = const {},
  });

  final int deckId;
  final List<CardEntity> queue;
  final int currentIndex;
  final bool isAnswerRevealed;
  final bool isCompleted;
  final List<StudySessionHistoryEntry> undoStack;
  final bool isCram;
  final CustomStudyConfig? customStudyConfig;
  final Map<Rating, String> intervalPreviews;

  bool get canUndo => undoStack.isNotEmpty;

  CardEntity? get currentCard {
    if (isCompleted || currentIndex >= queue.length) return null;
    return queue[currentIndex];
  }

  int get totalCards => queue.length;
  int get remainingCards => isCompleted ? 0 : queue.length - currentIndex;

  StudySessionState copyWith({
    int? deckId,
    List<CardEntity>? queue,
    int? currentIndex,
    bool? isAnswerRevealed,
    bool? isCompleted,
    List<StudySessionHistoryEntry>? undoStack,
    bool? isCram,
    CustomStudyConfig? customStudyConfig,
    Map<Rating, String>? intervalPreviews,
  }) {
    return StudySessionState(
      deckId: deckId ?? this.deckId,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      isCompleted: isCompleted ?? this.isCompleted,
      undoStack: undoStack ?? this.undoStack,
      isCram: isCram ?? this.isCram,
      customStudyConfig: customStudyConfig ?? this.customStudyConfig,
      intervalPreviews: intervalPreviews ?? this.intervalPreviews,
    );
  }
}

@riverpod
class StudySessionController extends _$StudySessionController {
  @override
  FutureOr<StudySessionState> build(
    int deckId, [
    CustomStudyConfig? customStudyConfig,
  ]) async {
    final dao = ref.watch(studySessionDaoProvider);
    final now = ref.read(clockProvider)();
    final List<Card> cards;

    if (customStudyConfig != null) {
      cards = await dao.fetchCustomStudyCards(
        deckId: deckId,
        now: now,
        scope: customStudyConfig.scope,
        tagId: customStudyConfig.tagId,
        daysAhead: customStudyConfig.daysAhead,
      );
    } else {
      cards = await dao.fetchDueCards(deckId, cutoff: now);
    }

    final cardEntities = cards.map((c) => c.toEntity()).toList();
    final isCram = customStudyConfig?.isCram ?? false;
    final firstCard = cardEntities.isNotEmpty ? cardEntities.first : null;

    return StudySessionState(
      deckId: deckId,
      queue: cardEntities,
      currentIndex: 0,
      isAnswerRevealed: false,
      isCompleted: cardEntities.isEmpty,
      isCram: isCram,
      customStudyConfig: customStudyConfig,
      intervalPreviews: _calculateIntervalPreviews(firstCard, isCram),
    );
  }

  void revealAnswer() {
    final current = state.value;
    if (current == null || current.isCompleted) return;
    state = AsyncData(current.copyWith(isAnswerRevealed: true));
  }

  Future<void> submitRating(Rating rating) async {
    final current = state.value;
    if (current == null || current.currentCard == null) return;

    final currentCard = current.currentCard!;
    final now = ref.read(clockProvider)();

    try {
      if (current.isCram) {
        final updatedQueue = List<CardEntity>.from(current.queue);
        final isRequeued = rating == Rating.again;
        if (isRequeued) {
          updatedQueue.add(currentCard);
        }
        final nextIndex = current.currentIndex + 1;
        final isCompleted = nextIndex >= updatedQueue.length;
        final nextCard = !isCompleted && nextIndex < updatedQueue.length
            ? updatedQueue[nextIndex]
            : null;

        final undoEntry = StudySessionHistoryEntry(
          card: currentCard,
          index: current.currentIndex,
          requeued: isRequeued,
        );

        state = AsyncData(
          current.copyWith(
            queue: updatedQueue,
            currentIndex: nextIndex,
            isAnswerRevealed: false,
            isCompleted: isCompleted,
            undoStack: [...current.undoStack, undoEntry],
            intervalPreviews: _calculateIntervalPreviews(nextCard, true),
          ),
        );
        return;
      }

      final fsrsCard = currentCard.toFsrsCard();
      final fsrsParams = ref.read(fsrsParametersControllerProvider);
      final engine = FsrsEngine(fsrsParams);
      final recordLog = engine.schedule(fsrsCard, rating, now);

      final dao = ref.read(studySessionDaoProvider);
      final reviewLogId = await dao.recordReview(
        cardId: currentCard.id,
        updatedCard: recordLog.card,
        logSnapshot: recordLog.log,
      );

      final nextIndex = current.currentIndex + 1;
      final isCompleted = nextIndex >= current.queue.length;
      final nextCard = !isCompleted && nextIndex < current.queue.length
          ? current.queue[nextIndex]
          : null;

      final undoEntry = StudySessionHistoryEntry(
        card: currentCard,
        index: current.currentIndex,
        reviewLogId: reviewLogId,
      );

      state = AsyncData(
        current.copyWith(
          currentIndex: nextIndex,
          isAnswerRevealed: false,
          isCompleted: isCompleted,
          undoStack: [...current.undoStack, undoEntry],
          intervalPreviews: _calculateIntervalPreviews(nextCard, false),
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> undoReview() async {
    final current = state.value;
    if (current == null || !current.canUndo) return;

    try {
      final lastEntry = current.undoStack.last;
      final newUndoStack = List<StudySessionHistoryEntry>.from(
        current.undoStack,
      )..removeLast();

      if (!current.isCram && lastEntry.reviewLogId != null) {
        final dao = ref.read(studySessionDaoProvider);
        await dao.undoReview(
          cardId: lastEntry.card.id,
          previousCard: lastEntry.card.toFsrsCard(),
          reviewLogId: lastEntry.reviewLogId!,
        );
      }

      final updatedQueue = List<CardEntity>.from(current.queue);
      if (lastEntry.requeued && updatedQueue.isNotEmpty) {
        updatedQueue.removeLast();
      }
      if (lastEntry.index < updatedQueue.length) {
        updatedQueue[lastEntry.index] = lastEntry.card;
      }

      final prevCard = updatedQueue[lastEntry.index];
      state = AsyncData(
        current.copyWith(
          queue: updatedQueue,
          currentIndex: lastEntry.index,
          isAnswerRevealed: false,
          isCompleted: false,
          undoStack: newUndoStack,
          intervalPreviews: _calculateIntervalPreviews(
            prevCard,
            current.isCram,
          ),
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> suspendCurrentCard() async {
    final current = state.value;
    if (current == null || current.currentCard == null) return;
    final card = current.currentCard!;

    try {
      final dao = ref.read(cardsDaoProvider);
      await dao.setCardSuspended(card.id, true);

      final updatedQueue = List<CardEntity>.from(current.queue)
        ..removeAt(current.currentIndex);
      final isCompleted =
          updatedQueue.isEmpty || current.currentIndex >= updatedQueue.length;
      final nextCard =
          !isCompleted && current.currentIndex < updatedQueue.length
          ? updatedQueue[current.currentIndex]
          : null;

      state = AsyncData(
        current.copyWith(
          queue: updatedQueue,
          isAnswerRevealed: false,
          isCompleted: isCompleted,
          undoStack: const [],
          intervalPreviews: _calculateIntervalPreviews(
            nextCard,
            current.isCram,
          ),
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> buryCurrentCard() async {
    final current = state.value;
    if (current == null || current.currentCard == null) return;
    final card = current.currentCard!;

    try {
      final dao = ref.read(cardsDaoProvider);
      await dao.buryCardUntilTomorrow(card.id);

      final updatedQueue = List<CardEntity>.from(current.queue)
        ..removeAt(current.currentIndex);
      final isCompleted =
          updatedQueue.isEmpty || current.currentIndex >= updatedQueue.length;
      final nextCard =
          !isCompleted && current.currentIndex < updatedQueue.length
          ? updatedQueue[current.currentIndex]
          : null;

      state = AsyncData(
        current.copyWith(
          queue: updatedQueue,
          isAnswerRevealed: false,
          isCompleted: isCompleted,
          undoStack: const [],
          intervalPreviews: _calculateIntervalPreviews(
            nextCard,
            current.isCram,
          ),
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Map<Rating, String> getIntervalPreviews() {
    return state.value?.intervalPreviews ?? const {};
  }

  Map<Rating, String> _calculateIntervalPreviews(
    CardEntity? card,
    bool isCram,
  ) {
    if (card == null) return const {};

    if (isCram) {
      return const {
        Rating.again: 'Re-queue',
        Rating.hard: 'Pass',
        Rating.good: 'Pass',
        Rating.easy: 'Pass',
      };
    }

    final now = ref.read(clockProvider)();
    final fsrsCard = card.toFsrsCard();
    final fsrsParams = ref.read(fsrsParametersControllerProvider);
    final engine = FsrsEngine(fsrsParams);
    final repeats = engine.repeat(fsrsCard, now);

    return repeats.map((rating, recordLog) {
      final days = recordLog.log.scheduledDays;
      final text = _formatInterval(rating, days);
      return MapEntry(rating, text);
    });
  }

  String _formatInterval(Rating rating, int days) {
    if (rating == Rating.again) {
      return '10m';
    }
    if (days < 30) {
      return '${days}d';
    } else if (days < 365) {
      final months = (days / 30).round();
      return '${months}mo';
    } else {
      final years = (days / 365).round();
      return '${years}y';
    }
  }
}
