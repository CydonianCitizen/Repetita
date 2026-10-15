import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/display_refresh_rate_service.dart';
import '../../domain/refresh_rate_preference.dart';

part 'refresh_rate_controller.g.dart';

@Riverpod(keepAlive: true)
class RefreshRateController extends _$RefreshRateController {
  static const _key = 'app_refresh_rate';
  static const _service = DisplayRefreshRateService();

  @override
  RefreshRatePreference build() {
    _loadFromDb();
    return RefreshRatePreference.system;
  }

  Future<void> _loadFromDb() async {
    try {
      final db = ref.read(databaseProvider);
      final saved = await db.getSetting(_key);
      if (saved != null) {
        final pref = RefreshRatePreference.values
            .cast<RefreshRatePreference?>()
            .firstWhere((p) => p?.name == saved, orElse: () => null);
        if (pref != null && ref.mounted) {
          state = pref;
          await _service.setRefreshRate(pref);
        }
      }
    } catch (e) {
      debugPrint('Failed to load refresh rate preference: $e');
    }
  }

  Future<void> setPreference(RefreshRatePreference preference) async {
    state = preference;
    await _service.setRefreshRate(preference);
    try {
      await ref.read(databaseProvider).setSetting(_key, preference.name);
    } catch (e) {
      debugPrint('Failed to save refresh rate preference: $e');
    }
  }
}
