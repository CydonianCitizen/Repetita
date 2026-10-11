import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  Future<int> createCard({required String front, required String back}) async {
    final dao = ref.read(cardsDaoProvider);
    return dao.createCard(deckId: deckId, front: front, back: back);
  }

  Future<void> updateCard({
    required int id,
    required String front,
    required String back,
  }) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.updateCardContent(id: id, front: front, back: back);
  }

  Future<void> deleteCard(int id) async {
    final dao = ref.read(cardsDaoProvider);
    await dao.deleteCard(id);
  }
}
