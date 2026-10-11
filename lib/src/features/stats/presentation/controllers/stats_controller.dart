import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/stats_dao_provider.dart';
import '../../domain/stats_models.dart';

part 'stats_controller.g.dart';

@riverpod
class StatsController extends _$StatsController {
  @override
  FutureOr<StatsData> build({int? deckId}) async {
    final dao = ref.watch(statsDaoProvider);
    final now = DateTime.now().toUtc();

    final stateCounts = await dao.getCardStateCounts(deckId: deckId);
    final retentionRate = await dao.getRetentionRate(deckId: deckId);
    final totalReviews = await dao.getTotalReviewsCount(deckId: deckId);
    final forecast = await dao.getDueForecast(
      deckId: deckId,
      days: 7,
      fromDate: now,
    );
    final dailyReviewCounts = await dao.getDailyReviewCounts(
      deckId: deckId,
      days: 105,
      toDate: now,
    );
    final currentStreak = await dao.getCurrentStreak(
      deckId: deckId,
      today: now,
    );

    return StatsData(
      stateCounts: stateCounts,
      retentionRate: retentionRate,
      totalReviews: totalReviews,
      forecast: forecast,
      dailyReviewCounts: dailyReviewCounts,
      currentStreak: currentStreak,
    );
  }
}
