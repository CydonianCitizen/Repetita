// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the installed app version (e.g. `v0.5.0`) read from
/// [PackageInfo], the single source of truth defined in pubspec.yaml.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// Provides the installed app version (e.g. `v0.5.0`) read from
/// [PackageInfo], the single source of truth defined in pubspec.yaml.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Provides the installed app version (e.g. `v0.5.0`) read from
  /// [PackageInfo], the single source of truth defined in pubspec.yaml.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'f828c62d453bc5def96d4002a8a3793f42dd82b8';
