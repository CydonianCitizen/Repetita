import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/haptic_intensity.dart';

part 'haptic_controller.g.dart';

@Riverpod(keepAlive: true)
class HapticFeedbackController extends _$HapticFeedbackController {
  @override
  HapticIntensity build() => HapticIntensity.medium;

  void setIntensity(HapticIntensity intensity) {
    state = intensity;
  }
}
