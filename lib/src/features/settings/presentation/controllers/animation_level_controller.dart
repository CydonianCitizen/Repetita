import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/animation_level.dart';

part 'animation_level_controller.g.dart';

@Riverpod(keepAlive: true)
class AnimationLevelController extends _$AnimationLevelController {
  @override
  AnimationLevel build() => AnimationLevel.standard;

  void setLevel(AnimationLevel level) {
    state = level;
  }
}
