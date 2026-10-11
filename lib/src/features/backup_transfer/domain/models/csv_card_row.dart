class CsvCardRow {
  const CsvCardRow({required this.front, required this.back, this.deckName});

  final String front;
  final String back;
  final String? deckName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CsvCardRow &&
          runtimeType == other.runtimeType &&
          front == other.front &&
          back == other.back &&
          deckName == other.deckName;

  @override
  int get hashCode => Object.hash(front, back, deckName);
}

class CsvImportResult {
  const CsvImportResult({
    required this.importedCount,
    required this.skippedCount,
  });

  final int importedCount;
  final int skippedCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CsvImportResult &&
          runtimeType == other.runtimeType &&
          importedCount == other.importedCount &&
          skippedCount == other.skippedCount;

  @override
  int get hashCode => Object.hash(importedCount, skippedCount);
}
