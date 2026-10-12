enum CustomStudyScope { allCards, byTag, reviewAhead }

class CustomStudyConfig {
  const CustomStudyConfig({
    required this.scope,
    this.tagId,
    this.daysAhead = 1,
    this.isCram = true,
  });

  final CustomStudyScope scope;
  final int? tagId;
  final int daysAhead;
  final bool isCram;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomStudyConfig &&
          runtimeType == other.runtimeType &&
          scope == other.scope &&
          tagId == other.tagId &&
          daysAhead == other.daysAhead &&
          isCram == other.isCram;

  @override
  int get hashCode => Object.hash(scope, tagId, daysAhead, isCram);
}
