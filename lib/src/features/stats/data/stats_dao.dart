import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/cards_table.dart';
import '../../../core/database/tables/review_logs_table.dart';
import '../domain/stats_models.dart';

part 'stats_dao.g.dart';

@DriftAccessor(tables: [Cards, ReviewLogs])
class StatsDao extends DatabaseAccessor<AppDatabase> with _$StatsDaoMixin {
  StatsDao(super.db);

  Future<CardStateCounts> getCardStateCounts({int? deckId}) async {
    final query = select(cards);
    if (deckId != null) {
      query.where((t) => t.deckId.equals(deckId));
    }
    final cardList = await query.get();

    int newCount = 0;
    int learningCount = 0;
    int reviewCount = 0;
    int relearningCount = 0;

    for (final c in cardList) {
      switch (c.state) {
        case 0:
          newCount++;
          break;
        case 1:
          learningCount++;
          break;
        case 2:
          reviewCount++;
          break;
        case 3:
          relearningCount++;
          break;
      }
    }

    return CardStateCounts(
      newCount: newCount,
      learningCount: learningCount,
      reviewCount: reviewCount,
      relearningCount: relearningCount,
    );
  }

  Future<double> getRetentionRate({int? deckId}) async {
    if (deckId == null) {
      final allLogs = await select(reviewLogs).get();
      if (allLogs.isEmpty) return 0.0;
      final successful = allLogs.where((l) => l.rating >= 2).length;
      return successful / allLogs.length;
    } else {
      final query = select(reviewLogs).join([
        innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId)),
      ])..where(cards.deckId.equals(deckId));
      final rows = await query.get();
      if (rows.isEmpty) return 0.0;
      final successful = rows.where((row) {
        final log = row.readTable(reviewLogs);
        return log.rating >= 2;
      }).length;
      return successful / rows.length;
    }
  }

  Future<int> getTotalReviewsCount({int? deckId}) async {
    if (deckId == null) {
      final countExp = reviewLogs.id.count();
      final query = selectOnly(reviewLogs)..addColumns([countExp]);
      final count = await query.map((r) => r.read(countExp)).getSingle();
      return count ?? 0;
    } else {
      final countExp = reviewLogs.id.count();
      final query =
          selectOnly(reviewLogs)
              .join([innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId))])
            ..where(cards.deckId.equals(deckId))
            ..addColumns([countExp]);
      final count = await query.map((r) => r.read(countExp)).getSingle();
      return count ?? 0;
    }
  }

  Future<List<ForecastDay>> getDueForecast({
    int? deckId,
    int days = 7,
    required DateTime fromDate,
  }) async {
    final query = select(cards);
    if (deckId != null) {
      query.where((t) => t.deckId.equals(deckId));
    }
    final cardList = await query.get();

    final fromUtc = fromDate.toUtc();
    final todayStart = DateTime.utc(fromUtc.year, fromUtc.month, fromUtc.day);

    final result = <ForecastDay>[];
    for (int i = 0; i < days; i++) {
      final dayStart = todayStart.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));

      int count = 0;
      for (final card in cardList) {
        final dueUtc = card.due.toUtc();
        if (i == 0) {
          if (card.state == 0 || dueUtc.isBefore(dayEnd)) {
            count++;
          }
        } else {
          if (card.state != 0 &&
              (dueUtc.isAfter(dayStart) || dueUtc.isAtSameMomentAs(dayStart)) &&
              dueUtc.isBefore(dayEnd)) {
            count++;
          }
        }
      }
      result.add(ForecastDay(date: dayStart, count: count));
    }

    return result;
  }
}
