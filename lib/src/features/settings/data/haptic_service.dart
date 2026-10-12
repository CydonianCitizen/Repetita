import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/algorithms/fsrs/models/fsrs_models.dart';
import '../domain/haptic_intensity.dart';

final hapticServiceProvider = Provider<HapticService>((ref) {
  return const HapticService();
});

class HapticService {
  const HapticService();

  Future<void> triggerRatingFeedback(
    Rating rating,
    HapticIntensity intensity,
  ) async {
    if (intensity.isOff) return;

    switch (rating) {
      case Rating.again:
        // Complete failure: distinctive warning/alert tactile pulse
        if (intensity == HapticIntensity.light) {
          await HapticFeedback.mediumImpact();
        } else {
          await HapticFeedback.heavyImpact();
          await Future<void>.delayed(const Duration(milliseconds: 60));
          await HapticFeedback.heavyImpact();
        }
        break;

      case Rating.hard:
        // High effort recall: firm tactile thud
        if (intensity == HapticIntensity.light) {
          await HapticFeedback.lightImpact();
        } else if (intensity == HapticIntensity.medium) {
          await HapticFeedback.mediumImpact();
        } else {
          await HapticFeedback.heavyImpact();
        }
        break;

      case Rating.good:
        // Standard successful recall: pleasant balanced tap
        if (intensity == HapticIntensity.light) {
          await HapticFeedback.selectionClick();
        } else if (intensity == HapticIntensity.medium) {
          await HapticFeedback.lightImpact();
        } else {
          await HapticFeedback.mediumImpact();
        }
        break;

      case Rating.easy:
        // Instant/effortless recall: crisp rapid double click
        if (intensity == HapticIntensity.light) {
          await HapticFeedback.selectionClick();
        } else if (intensity == HapticIntensity.medium) {
          await HapticFeedback.selectionClick();
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await HapticFeedback.selectionClick();
        } else {
          await HapticFeedback.lightImpact();
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await HapticFeedback.selectionClick();
        }
        break;
    }
  }

  Future<void> triggerTest(HapticIntensity intensity) async {
    if (intensity.isOff) return;

    switch (intensity) {
      case HapticIntensity.off:
        break;
      case HapticIntensity.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticIntensity.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticIntensity.strong:
        await HapticFeedback.heavyImpact();
        break;
    }
  }

  Future<void> triggerSelection(HapticIntensity intensity) async {
    if (intensity.isOff) return;
    await HapticFeedback.selectionClick();
  }
}
