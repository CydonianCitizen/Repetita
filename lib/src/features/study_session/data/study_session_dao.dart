import 'package:drift/drift.dart';

import '../../../core/algorithms/fsrs/models/fsrs_card.dart';
import '../../../core/algorithms/fsrs/models/record_log.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/tables/cards_table.dart';
import '../../../core/database/tables/review_logs_table.dart';

part 'study_session_dao.g.dart';

@DriftAccessor(tables: [Cards, ReviewLogs])
class StudySessionDao extends DatabaseAccessor<AppDatabase>
    with _$StudySessionDaoMixin {
  StudySessionDao(super.db);

  Future<List<Card>> fetchDueCards(int deckId, {required DateTime cutoff}) {
    final cutoffUtc = cutoff.toUtc();
    return (select(cards)
          ..where(
            (t) =>
                t.deckId.equals(deckId) &
                t.isSuspended.equals(false) &
                (t.buriedUntil.isNull() |
                    t.buriedUntil.isSmallerOrEqualValue(cutoffUtc)) &
                (t.due.isSmallerOrEqualValue(cutoffUtc) | t.state.equals(0)),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.due),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  Future<int> recordReview({
    required int cardId,
    required FsrsCard updatedCard,
    required ReviewLogSnapshot logSnapshot,
  }) {
    return transaction(() async {
      await (update(cards)..where((t) => t.id.equals(cardId))).write(
        CardsCompanion(
          state: Value(updatedCard.state.value),
          stability: Value(updatedCard.stability),
          difficulty: Value(updatedCard.difficulty),
          due: Value(updatedCard.due),
          lastReview: Value(updatedCard.lastReview),
          reps: Value(updatedCard.reps),
          lapses: Value(updatedCard.lapses),
        ),
      );

      final logId = await into(reviewLogs).insert(
        ReviewLogsCompanion.insert(
          cardId: cardId,
          rating: logSnapshot.rating.value,
          state: logSnapshot.state.value,
          due: logSnapshot.due,
          stability: logSnapshot.stability,
          difficulty: logSnapshot.difficulty,
          elapsedDays: logSnapshot.elapsedDays,
          lastElapsedDays: logSnapshot.lastElapsedDays,
          scheduledDays: logSnapshot.scheduledDays,
          reviewedAt: logSnapshot.reviewedAt,
        ),
      );

      return logId;
    });
  }

  Future<void> undoReview({
    required int cardId,
    required FsrsCard previousCard,
    required int reviewLogId,
  }) {
    return transaction(() async {
      await (update(cards)..where((t) => t.id.equals(cardId))).write(
        CardsCompanion(
          state: Value(previousCard.state.value),
          stability: Value(previousCard.stability),
          difficulty: Value(previousCard.difficulty),
          due: Value(previousCard.due),
          lastReview: Value(previousCard.lastReview),
          reps: Value(previousCard.reps),
          lapses: Value(previousCard.lapses),
        ),
      );

      await (delete(reviewLogs)..where((t) => t.id.equals(reviewLogId))).go();
    });
  }
}
