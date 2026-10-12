enum CustomStudyScope { allCards, byTag, reviewAhead }

class CustomStudyConfig {
  const CustomStudyConfig({
    required this.scope,
    this.tagId,
    this.daysAhead = 1,
    this.isCram = true,
    bool? recordReviews,
  }) : recordReviews = recordReviews ?? !isCram;

  final CustomStudyScope scope;
  final int? tagId;
  final int daysAhead;
  final bool isCram;
  final bool recordReviews;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomStudyConfig &&
          runtimeType == other.runtimeType &&
          scope == other.scope &&
          tagId == other.tagId &&
          daysAhead == other.daysAhead &&
          isCram == other.isCram &&
          recordReviews == other.recordReviews;

  @override
  int get hashCode =>
      Object.hash(scope, tagId, daysAhead, isCram, recordReviews);
}
