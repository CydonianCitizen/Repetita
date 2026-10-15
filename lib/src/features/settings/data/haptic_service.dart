import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/algorithms/fsrs/models/fsrs_models.dart';
import '../domain/haptic_intensity.dart';

final hapticServiceProvider = Provider<HapticService>((ref) {
  return const HapticService();
});

class HapticService {
  const HapticService();

  static const MethodChannel _channel = MethodChannel(
    'com.example.repetita/haptics',
  );

  Future<void> _vibrate(
    String nativeType,
    Future<void> Function() flutterFallback,
  ) async {
    await flutterFallback();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod<bool>('vibrate', {'type': nativeType});
      } catch (_) {
        // Ignored when running in widget test environment
      }
    }
  }

  Future<void> triggerRatingFeedback(
    Rating rating,
    HapticIntensity intensity,
  ) async {
    if (intensity.isOff) return;

    switch (rating) {
      case Rating.again:
        // Complete failure: distinctive warning/alert tactile pulse
        if (intensity == HapticIntensity.light) {
          await _vibrate('medium', () => HapticFeedback.mediumImpact());
        } else {
          await _vibrate('heavy', () => HapticFeedback.heavyImpact());
          await Future<void>.delayed(const Duration(milliseconds: 60));
          await _vibrate('heavy', () => HapticFeedback.heavyImpact());
        }
        break;

      case Rating.hard:
        // High effort recall: firm tactile thud
        if (intensity == HapticIntensity.light) {
          await _vibrate('light', () => HapticFeedback.lightImpact());
        } else if (intensity == HapticIntensity.medium) {
          await _vibrate('medium', () => HapticFeedback.mediumImpact());
        } else {
          await _vibrate('heavy', () => HapticFeedback.heavyImpact());
        }
        break;

      case Rating.good:
        // Standard successful recall: pleasant balanced tap
        if (intensity == HapticIntensity.light) {
          await _vibrate('click', () => HapticFeedback.selectionClick());
        } else if (intensity == HapticIntensity.medium) {
          await _vibrate('light', () => HapticFeedback.lightImpact());
        } else {
          await _vibrate('medium', () => HapticFeedback.mediumImpact());
        }
        break;

      case Rating.easy:
        // Instant/effortless recall: crisp rapid double click
        if (intensity == HapticIntensity.light) {
          await _vibrate('click', () => HapticFeedback.selectionClick());
        } else if (intensity == HapticIntensity.medium) {
          await _vibrate('click', () => HapticFeedback.selectionClick());
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await _vibrate('click', () => HapticFeedback.selectionClick());
        } else {
          await _vibrate('light', () => HapticFeedback.lightImpact());
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await _vibrate('click', () => HapticFeedback.selectionClick());
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
        await _vibrate('light', () => HapticFeedback.lightImpact());
        break;
      case HapticIntensity.medium:
        await _vibrate('medium', () => HapticFeedback.mediumImpact());
        break;
      case HapticIntensity.strong:
        await _vibrate('heavy', () => HapticFeedback.heavyImpact());
        break;
    }
  }

  Future<void> triggerSelection(HapticIntensity intensity) async {
    if (intensity.isOff) return;
    await _vibrate('click', () => HapticFeedback.selectionClick());
  }
}
