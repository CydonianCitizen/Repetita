// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'srs_scheduler_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(srsScheduler)
final srsSchedulerProvider = SrsSchedulerProvider._();

final class SrsSchedulerProvider
    extends $FunctionalProvider<SrsScheduler, SrsScheduler, SrsScheduler>
    with $Provider<SrsScheduler> {
  SrsSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'srsSchedulerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$srsSchedulerHash();

  @$internal
  @override
  $ProviderElement<SrsScheduler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SrsScheduler create(Ref ref) {
    return srsScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SrsScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SrsScheduler>(value),
    );
  }
}

String _$srsSchedulerHash() => r'6333378d2f801e58c6a04c99970cb88045c1f1a4';
