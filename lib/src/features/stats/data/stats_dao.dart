import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
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

  Future<Map<DateTime, int>> getDailyReviewCounts({
    int? deckId,
    int days = 105,
    required DateTime toDate,
  }) async {
    final toUtc = toDate.toUtc();
    final endOfDay = DateTime.utc(
      toUtc.year,
      toUtc.month,
      toUtc.day,
      23,
      59,
      59,
      999,
    );
    final startDay = DateTime.utc(
      toUtc.year,
      toUtc.month,
      toUtc.day,
    ).subtract(Duration(days: days - 1));

    final query = selectOnly(reviewLogs);
    if (deckId != null) {
      query.join([innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId))]);
      query.where(
        cards.deckId.equals(deckId) &
            reviewLogs.reviewedAt.isBiggerOrEqualValue(startDay) &
            reviewLogs.reviewedAt.isSmallerOrEqualValue(endOfDay),
      );
    } else {
      query.where(
        reviewLogs.reviewedAt.isBiggerOrEqualValue(startDay) &
            reviewLogs.reviewedAt.isSmallerOrEqualValue(endOfDay),
      );
    }
    query.addColumns([reviewLogs.reviewedAt]);

    final rows = await query.get();
    final map = <DateTime, int>{};
    for (final row in rows) {
      final dt = row.read(reviewLogs.reviewedAt);
      if (dt != null) {
        final utc = dt.toUtc();
        final dayKey = DateTime.utc(utc.year, utc.month, utc.day);
        map[dayKey] = (map[dayKey] ?? 0) + 1;
      }
    }
    return map;
  }

  Future<int> getCurrentStreak({int? deckId, required DateTime today}) async {
    final query = selectOnly(reviewLogs);
    if (deckId != null) {
      query.join([innerJoin(cards, cards.id.equalsExp(reviewLogs.cardId))]);
      query.where(cards.deckId.equals(deckId));
    }
    query.addColumns([reviewLogs.reviewedAt]);

    final rows = await query.get();
    final uniqueDays = <DateTime>{};
    for (final row in rows) {
      final dt = row.read(reviewLogs.reviewedAt);
      if (dt != null) {
        final utc = dt.toUtc();
        uniqueDays.add(DateTime.utc(utc.year, utc.month, utc.day));
      }
    }

    return calculateStreak(uniqueDays, today);
  }
}
