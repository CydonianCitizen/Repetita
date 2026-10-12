// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fsrs_parameters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FsrsParametersController)
final fsrsParametersControllerProvider = FsrsParametersControllerProvider._();

final class FsrsParametersControllerProvider
    extends $NotifierProvider<FsrsParametersController, FsrsParameters> {
  FsrsParametersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fsrsParametersControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fsrsParametersControllerHash();

  @$internal
  @override
  FsrsParametersController create() => FsrsParametersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FsrsParameters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FsrsParameters>(value),
    );
  }
}

String _$fsrsParametersControllerHash() =>
    r'b57221a39d79a29ac6a637049d99b78d3e855237';

abstract class _$FsrsParametersController extends $Notifier<FsrsParameters> {
  FsrsParameters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FsrsParameters, FsrsParameters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FsrsParameters, FsrsParameters>,
              FsrsParameters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
