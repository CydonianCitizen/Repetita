import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/algorithms/fsrs/models/fsrs_parameters.dart';
import '../../../../core/database/database_provider.dart';

part 'fsrs_parameters_controller.g.dart';

@Riverpod(keepAlive: true)
class FsrsParametersController extends _$FsrsParametersController {
  static const _retentionKey = 'fsrs_request_retention';
  static const _maxIntervalKey = 'fsrs_maximum_interval';

  @override
  FsrsParameters build() {
    _loadFromDb();
    return const FsrsParameters();
  }

  Future<void> _loadFromDb() async {
    final db = ref.read(databaseProvider);
    final retentionStr = await db.getSetting(_retentionKey);
    final maxIntervalStr = await db.getSetting(_maxIntervalKey);

    final retention = retentionStr != null
        ? double.tryParse(retentionStr) ?? 0.9
        : 0.9;
    final maxInterval = maxIntervalStr != null
        ? int.tryParse(maxIntervalStr) ?? 36500
        : 36500;

    if (retention != 0.9 || maxInterval != 36500) {
      state = FsrsParameters(
        requestRetention: retention,
        maximumInterval: maxInterval,
      );
    }
  }

  void setRequestRetention(double retention) {
    state = FsrsParameters(
      requestRetention: retention,
      maximumInterval: state.maximumInterval,
      w: state.w,
    );
    ref.read(databaseProvider).setSetting(
      _retentionKey,
      retention.toString(),
    );
  }

  void setMaximumInterval(int maxInterval) {
    state = FsrsParameters(
      requestRetention: state.requestRetention,
      maximumInterval: maxInterval,
      w: state.w,
    );
    ref.read(databaseProvider).setSetting(
      _maxIntervalKey,
      maxInterval.toString(),
    );
  }

  void resetToDefaults() {
    state = const FsrsParameters();
    final db = ref.read(databaseProvider);
    db.setSetting(_retentionKey, '0.9');
    db.setSetting(_maxIntervalKey, '36500');
  }
}
