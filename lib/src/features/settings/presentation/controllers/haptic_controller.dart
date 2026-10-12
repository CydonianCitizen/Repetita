import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/haptic_intensity.dart';

part 'haptic_controller.g.dart';

@Riverpod(keepAlive: true)
class HapticFeedbackController extends _$HapticFeedbackController {
  static const _key = 'app_haptic_intensity';

  @override
  HapticIntensity build() {
    _loadFromDb();
    return HapticIntensity.medium;
  }

  Future<void> _loadFromDb() async {
    try {
      final db = ref.read(databaseProvider);
      final saved = await db.getSetting(_key);
      if (saved != null && ref.mounted) {
        final intensity = HapticIntensity.values
            .cast<HapticIntensity?>()
            .firstWhere((i) => i?.name == saved, orElse: () => null);
        if (intensity != null) {
          state = intensity;
        }
      }
    } catch (e) {
      debugPrint('Failed to load haptic intensity: $e');
    }
  }

  Future<void> setIntensity(HapticIntensity intensity) async {
    state = intensity;
    try {
      await ref.read(databaseProvider).setSetting(_key, intensity.name);
    } catch (e) {
      debugPrint('Failed to save haptic intensity: $e');
    }
  }
}
