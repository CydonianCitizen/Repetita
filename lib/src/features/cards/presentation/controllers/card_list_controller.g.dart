// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
    r'99c32621b9c69798bc45afcca0feb770f0c7348a';

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
