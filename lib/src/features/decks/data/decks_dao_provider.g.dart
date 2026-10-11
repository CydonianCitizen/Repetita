// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decks_dao_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(decksDao)
final decksDaoProvider = DecksDaoProvider._();

final class DecksDaoProvider
    extends $FunctionalProvider<DecksDao, DecksDao, DecksDao>
    with $Provider<DecksDao> {
  DecksDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'decksDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$decksDaoHash();

  @$internal
  @override
  $ProviderElement<DecksDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DecksDao create(Ref ref) {
    return decksDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DecksDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DecksDao>(value),
    );
  }
}

String _$decksDaoHash() => r'35c46e8ebf8a9f9f11a489b6e863106ec6129166';
