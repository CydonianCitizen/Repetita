class ClozeSegment {
  const ClozeSegment({
    required this.text,
    this.isCloze = false,
    this.isActive = false,
    this.hint,
  });

  final String text;
  final bool isCloze;
  final bool isActive;
  final String? hint;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClozeSegment &&
        other.text == text &&
        other.isCloze == isCloze &&
        other.isActive == isActive &&
        other.hint == hint;
  }

  @override
  int get hashCode => Object.hash(text, isCloze, isActive, hint);

  @override
  String toString() =>
      'ClozeSegment(text: "$text", isCloze: $isCloze, isActive: $isActive, hint: $hint)';
}
