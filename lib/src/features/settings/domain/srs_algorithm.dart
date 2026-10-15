enum SrsAlgorithm {
  fsrs,
  sm2;

  String get label => switch (this) {
    SrsAlgorithm.fsrs => 'FSRS (Default)',
    SrsAlgorithm.sm2 => 'SM-2 (Classic)',
  };
}
