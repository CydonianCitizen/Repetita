import 'dart:math';

class ExamPlanResult {
  const ExamPlanResult({
    required this.daysRemaining,
    required this.dailyNewCardsQuota,
    required this.estimatedDailyReviews,
    required this.isUnsustainable,
    required this.suggestedRetention,
  });

  final int daysRemaining;
  final int dailyNewCardsQuota;
  final int estimatedDailyReviews;
  final bool isUnsustainable;
  final double suggestedRetention;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamPlanResult &&
          runtimeType == other.runtimeType &&
          daysRemaining == other.daysRemaining &&
          dailyNewCardsQuota == other.dailyNewCardsQuota &&
          estimatedDailyReviews == other.estimatedDailyReviews &&
          isUnsustainable == other.isUnsustainable &&
          suggestedRetention == other.suggestedRetention;

  @override
  int get hashCode => Object.hash(
        daysRemaining,
        dailyNewCardsQuota,
        estimatedDailyReviews,
        isUnsustainable,
        suggestedRetention,
      );
}

class ExamStudyPlanner {
  const ExamStudyPlanner({
    this.maxDailyWorkload = 120,
    this.maxDailyNewCards = 50,
  });

  final int maxDailyWorkload;
  final int maxDailyNewCards;

  ExamPlanResult calculatePlan({
    required DateTime now,
    required DateTime examDate,
    required int newCardsCount,
    required int reviewCardsCount,
    double? targetRetention,
  }) {
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfExam = DateTime(examDate.year, examDate.month, examDate.day);
    final daysRemaining = max(0, startOfExam.difference(startOfToday).inDays);

    final double effectiveRetention = (targetRetention ?? 0.90).clamp(0.70, 0.97);

    if (daysRemaining == 0) {
      final totalPending = newCardsCount + reviewCardsCount;
      return ExamPlanResult(
        daysRemaining: 0,
        dailyNewCardsQuota: newCardsCount,
        estimatedDailyReviews: reviewCardsCount,
        isUnsustainable: totalPending > 0,
        suggestedRetention: effectiveRetention,
      );
    }

    final dailyNewCards = (newCardsCount / daysRemaining).ceil();
    final baseDailyReviews = (reviewCardsCount / daysRemaining).ceil();
    // In SRS, introducing N new cards/day introduces roughly ~1.5 review cards per day in the short term.
    final estimatedDailyReviews = baseDailyReviews + (dailyNewCards * 1.5).ceil();

    final totalDailyWorkload = dailyNewCards + estimatedDailyReviews;
    final isUnsustainable =
        dailyNewCards > maxDailyNewCards || totalDailyWorkload > maxDailyWorkload;

    return ExamPlanResult(
      daysRemaining: daysRemaining,
      dailyNewCardsQuota: dailyNewCards,
      estimatedDailyReviews: estimatedDailyReviews,
      isUnsustainable: isUnsustainable,
      suggestedRetention: effectiveRetention,
    );
  }
}
