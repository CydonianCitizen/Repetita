// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'srs_algorithm_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SrsAlgorithmController)
final srsAlgorithmControllerProvider = SrsAlgorithmControllerProvider._();

final class SrsAlgorithmControllerProvider
    extends $NotifierProvider<SrsAlgorithmController, SrsAlgorithm> {
  SrsAlgorithmControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'srsAlgorithmControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$srsAlgorithmControllerHash();

  @$internal
  @override
  SrsAlgorithmController create() => SrsAlgorithmController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SrsAlgorithm value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SrsAlgorithm>(value),
    );
  }
}

String _$srsAlgorithmControllerHash() =>
    r'cbcf8fbec80bbcc8c1c68fb2497cc6dcdd7fc63a';

abstract class _$SrsAlgorithmController extends $Notifier<SrsAlgorithm> {
  SrsAlgorithm build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SrsAlgorithm, SrsAlgorithm>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SrsAlgorithm, SrsAlgorithm>,
              SrsAlgorithm,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
