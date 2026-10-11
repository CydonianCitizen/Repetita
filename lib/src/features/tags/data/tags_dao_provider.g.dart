// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_dao_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tagsDao)
final tagsDaoProvider = TagsDaoProvider._();

final class TagsDaoProvider
    extends $FunctionalProvider<TagsDao, TagsDao, TagsDao>
    with $Provider<TagsDao> {
  TagsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagsDaoHash();

  @$internal
  @override
  $ProviderElement<TagsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TagsDao create(Ref ref) {
    return tagsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagsDao>(value),
    );
  }
}

String _$tagsDaoHash() => r'9ffe7376916acb29be49c19a38c155df45fff2d1';
