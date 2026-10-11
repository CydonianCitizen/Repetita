import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../tags/data/tags_dao_provider.dart';
import '../../data/cards_dao.dart';
import '../../data/cards_dao_provider.dart';
import '../../domain/card_entity.dart';

part 'card_list_controller.g.dart';

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
    final tagsDao = tagIds.isNotEmpty ? ref.read(tagsDaoProvider) : null;
    final cardId = await dao.createCard(
      deckId: deckId,
      front: front,
      back: back,
      clozeIndex: clozeIndex,
    );
    if (tagsDao != null) {
      await tagsDao.setCardTags(cardId, tagIds);
    }
    return cardId;
  }

  Future<void> updateCard({
    required int id,
    required String front,
    required String back,
    List<int>? tagIds,
  }) async {
    final dao = ref.read(cardsDaoProvider);
    final tagsDao = tagIds != null ? ref.read(tagsDaoProvider) : null;
    await dao.updateCardContent(id: id, front: front, back: back);
    if (tagsDao != null && tagIds != null) {
      await tagsDao.setCardTags(id, tagIds);
    }
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
    final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1));
    final tomorrowMidnight = DateTime.utc(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
    );
    await dao.buryCard(id, tomorrowMidnight);
  }

  Future<void> unburyCard(int id) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.unburyCard(id);
  }
}
