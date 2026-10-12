import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/animation_level.dart';

part 'animation_level_controller.g.dart';

@Riverpod(keepAlive: true)
class AnimationLevelController extends _$AnimationLevelController {
  static const _key = 'app_animation_level';

  @override
  AnimationLevel build() {
    _loadFromDb();
    return AnimationLevel.standard;
  }

  Future<void> _loadFromDb() async {
    try {
      final db = ref.read(databaseProvider);
      final saved = await db.getSetting(_key);
      if (saved != null && ref.mounted) {
        final level = AnimationLevel.values.cast<AnimationLevel?>().firstWhere(
          (l) => l?.name == saved,
          orElse: () => null,
        );
        if (level != null) {
          state = level;
        }
      }
    } catch (e) {
      debugPrint('Failed to load animation level: $e');
    }
  }

  Future<void> setLevel(AnimationLevel level) async {
    state = level;
    try {
      await ref.read(databaseProvider).setSetting(_key, level.name);
    } catch (e) {
      debugPrint('Failed to save animation level: $e');
    }
  }
}
