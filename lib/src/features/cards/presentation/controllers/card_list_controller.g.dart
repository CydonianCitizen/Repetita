// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cards of [deckId] filtered by the currently selected tag.
/// Recomputed only when the card list, the tag map or the filter change.

@ProviderFor(filteredDeckCards)
final filteredDeckCardsProvider = FilteredDeckCardsFamily._();

/// Cards of [deckId] filtered by the currently selected tag.
/// Recomputed only when the card list, the tag map or the filter change.

final class FilteredDeckCardsProvider
    extends
        $FunctionalProvider<
          List<CardEntity>,
          List<CardEntity>,
          List<CardEntity>
        >
    with $Provider<List<CardEntity>> {
  /// Cards of [deckId] filtered by the currently selected tag.
  /// Recomputed only when the card list, the tag map or the filter change.
  FilteredDeckCardsProvider._({
    required FilteredDeckCardsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'filteredDeckCardsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredDeckCardsHash();

  @override
  String toString() {
    return r'filteredDeckCardsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<CardEntity>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<CardEntity> create(Ref ref) {
    final argument = this.argument as int;
    return filteredDeckCards(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CardEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CardEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredDeckCardsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredDeckCardsHash() => r'7fd54e2638d14267d26b2f3f8b6362ad02cdf6f6';

/// Cards of [deckId] filtered by the currently selected tag.
/// Recomputed only when the card list, the tag map or the filter change.

final class FilteredDeckCardsFamily extends $Family
    with $FunctionalFamilyOverride<List<CardEntity>, int> {
  FilteredDeckCardsFamily._()
    : super(
        retry: null,
        name: r'filteredDeckCardsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cards of [deckId] filtered by the currently selected tag.
  /// Recomputed only when the card list, the tag map or the filter change.

  FilteredDeckCardsProvider call(int deckId) =>
      FilteredDeckCardsProvider._(argument: deckId, from: this);

  @override
  String toString() => r'filteredDeckCardsProvider';
}

@ProviderFor(CardListController)
final cardListControllerProvider = CardListControllerFamily._();

final class CardListControllerProvider
    extends $StreamNotifierProvider<CardListController, List<CardEntity>> {
  CardListControllerProvider._({
    required CardListControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'cardListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cardListControllerHash();

  @override
  String toString() {
    return r'cardListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CardListController create() => CardListController();

  @override
  bool operator ==(Object other) {
    return other is CardListControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cardListControllerHash() =>
    r'8c12e9e0a0b6ed4e18ad8c25310328befeaf4d20';

final class CardListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CardListController,
          AsyncValue<List<CardEntity>>,
          List<CardEntity>,
          Stream<List<CardEntity>>,
          int
        > {
  CardListControllerFamily._()
    : super(
        retry: null,
        name: r'cardListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CardListControllerProvider call(int deckId) =>
      CardListControllerProvider._(argument: deckId, from: this);

  @override
  String toString() => r'cardListControllerProvider';
}

abstract class _$CardListController extends $StreamNotifier<List<CardEntity>> {
  late final _$args = ref.$arg as int;
  int get deckId => _$args;

  Stream<List<CardEntity>> build(int deckId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CardEntity>>, List<CardEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CardEntity>>, List<CardEntity>>,
              AsyncValue<List<CardEntity>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
