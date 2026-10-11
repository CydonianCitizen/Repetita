enum HapticIntensity {
  off(0),
  light(1),
  medium(2),
  strong(3);

  const HapticIntensity(this.level);
  final int level;

  bool get isOff => this == HapticIntensity.off;

  static HapticIntensity fromLevel(int level) {
    switch (level) {
      case 0:
        return HapticIntensity.off;
      case 1:
        return HapticIntensity.light;
      case 2:
        return HapticIntensity.medium;
      case 3:
      default:
        return HapticIntensity.strong;
    }
  }
}
