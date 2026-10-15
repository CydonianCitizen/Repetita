enum RefreshRatePreference {
  system,
  powerSave,
  high;

  double get targetFps {
    switch (this) {
      case RefreshRatePreference.system:
        return 0.0; // 0.0 means system adaptive / dynamic
      case RefreshRatePreference.powerSave:
        return 60.0; // Fixed 60 Hz to minimize battery consumption
      case RefreshRatePreference.high:
        return 120.0; // Request maximum display capability (e.g. 90 Hz / 120 Hz)
    }
  }
}
