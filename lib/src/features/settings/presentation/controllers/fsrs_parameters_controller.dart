import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/algorithms/fsrs/models/fsrs_parameters.dart';

part 'fsrs_parameters_controller.g.dart';

@Riverpod(keepAlive: true)
class FsrsParametersController extends _$FsrsParametersController {
  @override
  FsrsParameters build() => const FsrsParameters();

  void setRequestRetention(double retention) {
    state = FsrsParameters(
      requestRetention: retention,
      maximumInterval: state.maximumInterval,
      w: state.w,
    );
  }

  void setMaximumInterval(int maxInterval) {
    state = FsrsParameters(
      requestRetention: state.requestRetention,
      maximumInterval: maxInterval,
      w: state.w,
    );
  }

  void resetToDefaults() {
    state = const FsrsParameters();
  }
}
