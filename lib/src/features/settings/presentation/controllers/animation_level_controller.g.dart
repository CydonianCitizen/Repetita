// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animation_level_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnimationLevelController)
final animationLevelControllerProvider = AnimationLevelControllerProvider._();

final class AnimationLevelControllerProvider
    extends $NotifierProvider<AnimationLevelController, AnimationLevel> {
  AnimationLevelControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'animationLevelControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$animationLevelControllerHash();

  @$internal
  @override
  AnimationLevelController create() => AnimationLevelController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnimationLevel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnimationLevel>(value),
    );
  }
}

String _$animationLevelControllerHash() =>
    r'42b79825f9a06d0caa865b1f1da503b4d8edc588';

abstract class _$AnimationLevelController extends $Notifier<AnimationLevel> {
  AnimationLevel build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AnimationLevel, AnimationLevel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnimationLevel, AnimationLevel>,
              AnimationLevel,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
