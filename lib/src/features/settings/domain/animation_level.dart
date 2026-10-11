enum AnimationLevel {
  reduced(0),
  standard(1),
  expressive(2);

  const AnimationLevel(this.value);
  final int value;

  static AnimationLevel fromValue(int val) {
    return switch (val) {
      0 => AnimationLevel.reduced,
      2 => AnimationLevel.expressive,
      _ => AnimationLevel.standard,
    };
  }

  bool get isReduced => this == AnimationLevel.reduced;
  bool get isStandard => this == AnimationLevel.standard;
  bool get isExpressive => this == AnimationLevel.expressive;
}
