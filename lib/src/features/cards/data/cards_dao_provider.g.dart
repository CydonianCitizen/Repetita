// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cards_dao_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cardsDao)
final cardsDaoProvider = CardsDaoProvider._();

final class CardsDaoProvider
    extends $FunctionalProvider<CardsDao, CardsDao, CardsDao>
    with $Provider<CardsDao> {
  CardsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardsDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardsDaoHash();

  @$internal
  @override
  $ProviderElement<CardsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CardsDao create(Ref ref) {
    return cardsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardsDao>(value),
    );
  }
}

String _$cardsDaoHash() => r'4d0aa5088d96524918602a139f2f72e3267eb9b2';
