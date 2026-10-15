import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/app_theme_mode.dart';

part 'theme_mode_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  static const _key = 'app_theme_mode';

  @override
  AppThemeMode build() {
    _loadFromDb();
    return AppThemeMode.system;
  }

  Future<void> _loadFromDb() async {
    try {
      final db = ref.read(databaseProvider);
      final saved = await db.getSetting(_key);
      if (saved != null) {
        final mode = AppThemeMode.values.cast<AppThemeMode?>().firstWhere(
          (m) => m?.name == saved,
          orElse: () => null,
        );
        if (mode != null && ref.mounted) {
          state = mode;
        }
      }
    } catch (e) {
      debugPrint('Failed to load theme mode: $e');
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    try {
      await ref.read(databaseProvider).setSetting(_key, mode.name);
    } catch (e) {
      debugPrint('Failed to save theme mode: $e');
    }
  }
}
