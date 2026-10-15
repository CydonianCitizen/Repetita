// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_rate_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RefreshRateController)
final refreshRateControllerProvider = RefreshRateControllerProvider._();

final class RefreshRateControllerProvider
    extends $NotifierProvider<RefreshRateController, RefreshRatePreference> {
  RefreshRateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshRateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshRateControllerHash();

  @$internal
  @override
  RefreshRateController create() => RefreshRateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RefreshRatePreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RefreshRatePreference>(value),
    );
  }
}

String _$refreshRateControllerHash() =>
    r'71380fa5f7f1f287203f38b405cbe5b97cccfdd6';

abstract class _$RefreshRateController
    extends $Notifier<RefreshRatePreference> {
  RefreshRatePreference build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RefreshRatePreference, RefreshRatePreference>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RefreshRatePreference, RefreshRatePreference>,
              RefreshRatePreference,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
