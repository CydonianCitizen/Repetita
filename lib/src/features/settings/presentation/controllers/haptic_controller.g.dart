// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'haptic_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HapticFeedbackController)
final hapticFeedbackControllerProvider = HapticFeedbackControllerProvider._();

final class HapticFeedbackControllerProvider
    extends $NotifierProvider<HapticFeedbackController, HapticIntensity> {
  HapticFeedbackControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticFeedbackControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticFeedbackControllerHash();

  @$internal
  @override
  HapticFeedbackController create() => HapticFeedbackController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HapticIntensity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HapticIntensity>(value),
    );
  }
}

String _$hapticFeedbackControllerHash() =>
    r'29be5671e739d8262a4f3b385b9d86245bca3de8';

abstract class _$HapticFeedbackController extends $Notifier<HapticIntensity> {
  HapticIntensity build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HapticIntensity, HapticIntensity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HapticIntensity, HapticIntensity>,
              HapticIntensity,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
