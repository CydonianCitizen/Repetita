class CardStateCounts {
  const CardStateCounts({
    this.newCount = 0,
    this.learningCount = 0,
    this.reviewCount = 0,
    this.relearningCount = 0,
  });

  final int newCount;
  final int learningCount;
  final int reviewCount;
  final int relearningCount;

  int get total => newCount + learningCount + reviewCount + relearningCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardStateCounts &&
          runtimeType == other.runtimeType &&
          newCount == other.newCount &&
          learningCount == other.learningCount &&
          reviewCount == other.reviewCount &&
          relearningCount == other.relearningCount;

  @override
  int get hashCode =>
      Object.hash(newCount, learningCount, reviewCount, relearningCount);
}

class ForecastDay {
  const ForecastDay({required this.date, required this.count});

  final DateTime date;
  final int count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForecastDay &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          count == other.count;

  @override
  int get hashCode => Object.hash(date, count);
}

class StatsData {
  const StatsData({
    required this.stateCounts,
    required this.retentionRate,
    required this.totalReviews,
    required this.forecast,
  });

  final CardStateCounts stateCounts;
  final double retentionRate;
  final int totalReviews;
  final List<ForecastDay> forecast;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatsData &&
          runtimeType == other.runtimeType &&
          stateCounts == other.stateCounts &&
          retentionRate == other.retentionRate &&
          totalReviews == other.totalReviews;

  @override
  int get hashCode =>
      Object.hash(stateCounts, retentionRate, totalReviews, forecast);
}
