import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/algorithms/fsrs/fsrs_engine.dart';
import '../../../../core/algorithms/srs/srs_scheduler.dart';
import '../../../settings/presentation/controllers/fsrs_parameters_controller.dart';

part 'srs_scheduler_provider.g.dart';

@riverpod
SrsScheduler srsScheduler(Ref ref) {
  final fsrsParams = ref.watch(fsrsParametersControllerProvider);
  return FsrsEngine(fsrsParams);
}
