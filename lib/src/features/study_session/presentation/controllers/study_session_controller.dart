import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/algorithms/fsrs/fsrs_engine.dart';
import '../../../../core/algorithms/fsrs/models/rating.dart';
import '../../../cards/data/cards_dao.dart';
import '../../../cards/data/cards_dao_provider.dart';
import '../../../cards/domain/card_entity.dart';
import '../../../../core/database/app_database.dart' show Card;
import '../../../settings/presentation/controllers/fsrs_parameters_controller.dart';
import '../../data/study_session_dao_provider.dart';
import '../../domain/models/custom_study_config.dart';

part 'study_session_controller.g.dart';

class StudySessionState {
  const StudySessionState({
    required this.deckId,
    this.queue = const [],
    this.currentIndex = 0,
    this.isAnswerRevealed = false,
    this.isCompleted = false,
    this.lastReviewedCard,
    this.lastReviewLogId,
    this.isCram = false,
    this.customStudyConfig,
  });

  final int deckId;
  final List<CardEntity> queue;
  final int currentIndex;
  final bool isAnswerRevealed;
  final bool isCompleted;
  final CardEntity? lastReviewedCard;
  final int? lastReviewLogId;
  final bool isCram;
  final CustomStudyConfig? customStudyConfig;

  bool get canUndo {
    if (lastReviewedCard == null) return false;
    if (isCram) return true;
    return lastReviewLogId != null;
  }

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
    CardEntity? lastReviewedCard,
    int? lastReviewLogId,
    bool? isCram,
    CustomStudyConfig? customStudyConfig,
    bool clearUndo = false,
  }) {
    return StudySessionState(
      deckId: deckId ?? this.deckId,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      isCompleted: isCompleted ?? this.isCompleted,
      lastReviewedCard: clearUndo
          ? null
          : (lastReviewedCard ?? this.lastReviewedCard),
      lastReviewLogId: clearUndo
          ? null
          : (lastReviewLogId ?? this.lastReviewLogId),
      isCram: isCram ?? this.isCram,
      customStudyConfig: customStudyConfig ?? this.customStudyConfig,
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
    final now = DateTime.now().toUtc();
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

    return StudySessionState(
      deckId: deckId,
      queue: cardEntities,
      currentIndex: 0,
      isAnswerRevealed: false,
      isCompleted: cardEntities.isEmpty,
      isCram: customStudyConfig?.isCram ?? false,
      customStudyConfig: customStudyConfig,
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
    final now = DateTime.now().toUtc();

    if (current.isCram) {
      final updatedQueue = List<CardEntity>.from(current.queue);
      if (rating == Rating.again) {
        updatedQueue.add(currentCard);
      }
      final nextIndex = current.currentIndex + 1;
      final isCompleted = nextIndex >= updatedQueue.length;

      state = AsyncData(
        current.copyWith(
          queue: updatedQueue,
          currentIndex: nextIndex,
          isAnswerRevealed: false,
          isCompleted: isCompleted,
          lastReviewedCard: currentCard,
          lastReviewLogId: null,
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

    state = AsyncData(
      current.copyWith(
        currentIndex: nextIndex,
        isAnswerRevealed: false,
        isCompleted: isCompleted,
        lastReviewedCard: currentCard,
        lastReviewLogId: reviewLogId,
      ),
    );
  }

  Future<void> undoReview() async {
    final current = state.value;
    if (current == null || !current.canUndo) return;

    final prevCard = current.lastReviewedCard!;

    if (current.isCram) {
      final prevIndex = current.currentIndex > 0 ? current.currentIndex - 1 : 0;
      final updatedQueue = List<CardEntity>.from(current.queue);
      if (updatedQueue.length > current.totalCards) {
        updatedQueue.removeLast();
      }
      state = AsyncData(
        current.copyWith(
          queue: updatedQueue,
          currentIndex: prevIndex,
          isAnswerRevealed: false,
          isCompleted: false,
          clearUndo: true,
        ),
      );
      return;
    }

    final prevLogId = current.lastReviewLogId!;
    final dao = ref.read(studySessionDaoProvider);
    await dao.undoReview(
      cardId: prevCard.id,
      previousCard: prevCard.toFsrsCard(),
      reviewLogId: prevLogId,
    );

    final prevIndex = current.currentIndex > 0 ? current.currentIndex - 1 : 0;
    final updatedQueue = List<CardEntity>.from(current.queue);
    if (prevIndex < updatedQueue.length) {
      updatedQueue[prevIndex] = prevCard;
    }

    state = AsyncData(
      current.copyWith(
        queue: updatedQueue,
        currentIndex: prevIndex,
        isAnswerRevealed: false,
        isCompleted: false,
        clearUndo: true,
      ),
    );
  }

  Map<Rating, String> getIntervalPreviews() {
    final current = state.value;
    final card = current?.currentCard;
    if (card == null) return {};

    if (current?.isCram == true) {
      return {
        Rating.again: 'Re-queue',
        Rating.hard: 'Pass',
        Rating.good: 'Pass',
        Rating.easy: 'Pass',
      };
    }

    final now = DateTime.now().toUtc();
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

  Future<void> suspendCurrentCard() async {
    final current = state.value;
    if (current == null || current.currentCard == null) return;
    final card = current.currentCard!;
    final dao = ref.read(cardsDaoProvider);
    await dao.setCardSuspended(card.id, true);

    final updatedQueue = List<CardEntity>.from(current.queue)
      ..removeAt(current.currentIndex);
    final isCompleted =
        updatedQueue.isEmpty || current.currentIndex >= updatedQueue.length;

    state = AsyncData(
      current.copyWith(
        queue: updatedQueue,
        isAnswerRevealed: false,
        isCompleted: isCompleted,
        clearUndo: true,
      ),
    );
  }

  Future<void> buryCurrentCard() async {
    final current = state.value;
    if (current == null || current.currentCard == null) return;
    final card = current.currentCard!;
    final dao = ref.read(cardsDaoProvider);
    final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1));
    final tomorrowMidnight = DateTime.utc(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
    );
    await dao.buryCard(card.id, tomorrowMidnight);

    final updatedQueue = List<CardEntity>.from(current.queue)
      ..removeAt(current.currentIndex);
    final isCompleted =
        updatedQueue.isEmpty || current.currentIndex >= updatedQueue.length;

    state = AsyncData(
      current.copyWith(
        queue: updatedQueue,
        isAnswerRevealed: false,
        isCompleted: isCompleted,
        clearUndo: true,
      ),
    );
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
