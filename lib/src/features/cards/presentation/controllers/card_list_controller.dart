import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../../data/cards_dao.dart';
import '../../domain/card_entity.dart';

part 'card_list_controller.g.dart';

/// Page size for the rendered card list; further rows load in chunks.
const int kCardListPageSize = 100;

/// Cards of [deckId] filtered by the currently selected tag.
/// Recomputed only when the card list, the tag map or the filter change.
@riverpod
List<CardEntity> filteredDeckCards(Ref ref, int deckId) {
  final cards =
      ref.watch(cardListControllerProvider(deckId)).value ??
      const <CardEntity>[];
  final selectedTagId = ref.watch(deckTagFilterProvider);
  if (selectedTagId == null) return cards;
  final tagsMap = ref.watch(deckTagsProvider(deckId)).value;
  return cards
      .where(
        (c) => (tagsMap?[c.id] ?? const []).any((t) => t.id == selectedTagId),
      )
      .toList();
}

@riverpod
class CardListController extends _$CardListController {
  @override
  Stream<List<CardEntity>> build(int deckId) {
    final dao = ref.watch(cardsDaoProvider);
    return dao
        .watchCardsByDeck(deckId)
        .map((cards) => cards.map((c) => c.toEntity()).toList());
  }

  Future<int> createCard({
    required String front,
    required String back,
    int? clozeIndex,
    List<int> tagIds = const [],
  }) async {
    final dao = ref.read(cardsDaoProvider);
    final tagsDao = ref.read(tagsDaoProvider);
    return dao.attachedDatabase.transaction(() async {
      final cardId = await dao.createCard(
        deckId: deckId,
        front: front,
        back: back,
        clozeIndex: clozeIndex,
      );
      if (tagIds.isNotEmpty) {
        await tagsDao.setCardTags(cardId, tagIds);
      }
      return cardId;
    });
  }

  Future<List<int>> createClozeCards({
    required String front,
    required String back,
    required Iterable<int> clozeIndices,
    List<int> tagIds = const [],
  }) async {
    final dao = ref.read(cardsDaoProvider);
    final tagsDao = ref.read(tagsDaoProvider);
    return dao.attachedDatabase.transaction(() async {
      final cardIds = <int>[];
      for (final idx in clozeIndices) {
        final cardId = await dao.createCard(
          deckId: deckId,
          front: front,
          back: back,
          clozeIndex: idx,
        );
        if (tagIds.isNotEmpty) {
          await tagsDao.setCardTags(cardId, tagIds);
        }
        cardIds.add(cardId);
      }
      return cardIds;
    });
  }

  Future<void> updateCard({
    required int id,
    required String front,
    required String back,
    List<int>? tagIds,
  }) async {
    final dao = ref.read(cardsDaoProvider);
    final tagsDao = ref.read(tagsDaoProvider);
    await dao.attachedDatabase.transaction(() async {
      await dao.updateCardContent(id: id, front: front, back: back);
      if (tagIds != null) {
        await tagsDao.setCardTags(id, tagIds);
      }
    });
  }

  Future<void> deleteCard(int id) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.deleteCard(id);
  }

  Future<void> toggleSuspendCard(int id, bool currentSuspended) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.setCardSuspended(id, !currentSuspended);
  }

  Future<void> buryCard(int id) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.buryCardUntilTomorrow(id);
  }

  Future<void> unburyCard(int id) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.unburyCard(id);
  }
}
