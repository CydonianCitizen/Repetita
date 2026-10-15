import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/algorithms/fsrs/fsrs_engine.dart';
import '../../../../core/algorithms/sm2/sm2_engine.dart';
import '../../../../core/algorithms/srs/srs_scheduler.dart';
import '../../../settings/domain/srs_algorithm.dart';
import '../../../settings/presentation/controllers/fsrs_parameters_controller.dart';
import '../../../settings/presentation/controllers/srs_algorithm_controller.dart';

part 'srs_scheduler_provider.g.dart';

@riverpod
SrsScheduler srsScheduler(Ref ref) {
  final algorithm = ref.watch(srsAlgorithmControllerProvider);
  switch (algorithm) {
    case SrsAlgorithm.fsrs:
      final fsrsParams = ref.watch(fsrsParametersControllerProvider);
      return FsrsEngine(fsrsParams);
    case SrsAlgorithm.sm2:
      return const Sm2Engine();
  }
}
