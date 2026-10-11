class FsrsParameters {
  const FsrsParameters({
    this.requestRetention = 0.9,
    this.maximumInterval = 36500,
    this.w = defaultWeights,
  });

  final double requestRetention;
  final int maximumInterval;
  final List<double> w;

  static const List<double> defaultWeights = <double>[
    0.4,
    0.6,
    2.4,
    5.8,
    4.93,
    0.94,
    0.86,
    0.01,
    1.49,
    0.14,
    0.94,
    2.18,
    0.05,
    0.34,
    1.26,
    0.29,
    2.61,
  ];
}
