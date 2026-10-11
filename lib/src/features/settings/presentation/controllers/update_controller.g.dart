// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateService)
final updateServiceProvider = UpdateServiceProvider._();

final class UpdateServiceProvider
    extends $FunctionalProvider<UpdateService, UpdateService, UpdateService>
    with $Provider<UpdateService> {
  UpdateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateServiceHash();

  @$internal
  @override
  $ProviderElement<UpdateService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateService create(Ref ref) {
    return updateService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateService>(value),
    );
  }
}

String _$updateServiceHash() => r'1616131855fb61e308855d6064b3d30f5fd7acfe';

@ProviderFor(UpdateCheckController)
final updateCheckControllerProvider = UpdateCheckControllerProvider._();

final class UpdateCheckControllerProvider
    extends $NotifierProvider<UpdateCheckController, AsyncValue<UpdateInfo?>> {
  UpdateCheckControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateCheckControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateCheckControllerHash();

  @$internal
  @override
  UpdateCheckController create() => UpdateCheckController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<UpdateInfo?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<UpdateInfo?>>(value),
    );
  }
}

String _$updateCheckControllerHash() =>
    r'7d7d29471b2b93840e7f5c897e0dd94aa890b59b';

abstract class _$UpdateCheckController
    extends $Notifier<AsyncValue<UpdateInfo?>> {
  AsyncValue<UpdateInfo?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<UpdateInfo?>, AsyncValue<UpdateInfo?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UpdateInfo?>, AsyncValue<UpdateInfo?>>,
              AsyncValue<UpdateInfo?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
