import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';

part 'locale_controller.g.dart';

@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  static const _key = 'app_locale';

  @override
  Locale? build() {
    _loadFromDb();
    return null; // null indicates system default locale
  }

  Future<void> _loadFromDb() async {
    try {
      final db = ref.read(databaseProvider);
      final saved = await db.getSetting(_key);
      if (saved != null && ref.mounted) {
        if (saved == 'system' || saved.isEmpty) {
          state = null;
        } else {
          state = Locale(saved);
        }
      }
    } catch (e) {
      debugPrint('Failed to load locale: $e');
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    try {
      await ref
          .read(databaseProvider)
          .setSetting(_key, locale?.languageCode ?? 'system');
    } catch (e) {
      debugPrint('Failed to save locale: $e');
    }
  }
}
