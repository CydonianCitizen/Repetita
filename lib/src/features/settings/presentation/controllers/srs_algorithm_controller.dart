import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/srs_algorithm.dart';

part 'srs_algorithm_controller.g.dart';

@Riverpod(keepAlive: true)
class SrsAlgorithmController extends _$SrsAlgorithmController {
  static const _key = 'app_srs_algorithm';

  @override
  SrsAlgorithm build() {
    _loadFromDb();
    return SrsAlgorithm.fsrs;
  }

  Future<void> _loadFromDb() async {
    try {
      final db = ref.read(databaseProvider);
      final saved = await db.getSetting(_key);
      if (saved != null && ref.mounted) {
        final algo = SrsAlgorithm.values.firstWhere(
          (a) => a.name == saved,
          orElse: () => SrsAlgorithm.fsrs,
        );
        state = algo;
      }
    } catch (e) {
      debugPrint('Failed to load SRS algorithm: $e');
    }
  }

  Future<void> setAlgorithm(SrsAlgorithm algorithm) async {
    state = algorithm;
    try {
      await ref.read(databaseProvider).setSetting(_key, algorithm.name);
    } catch (e) {
      debugPrint('Failed to save SRS algorithm: $e');
    }
  }
}
