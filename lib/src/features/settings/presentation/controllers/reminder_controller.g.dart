// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'58da87941dbfa08925105dcc4d74091ee38c8593';

@ProviderFor(ReminderController)
final reminderControllerProvider = ReminderControllerProvider._();

final class ReminderControllerProvider
    extends $NotifierProvider<ReminderController, ReminderSettings> {
  ReminderControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderControllerHash();

  @$internal
  @override
  ReminderController create() => ReminderController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderSettings>(value),
    );
  }
}

String _$reminderControllerHash() =>
    r'fcabe0579f1c21ce887e89809524561a158ff399';

abstract class _$ReminderController extends $Notifier<ReminderSettings> {
  ReminderSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReminderSettings, ReminderSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReminderSettings, ReminderSettings>,
              ReminderSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
