import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/decks_dao.dart';
import '../../data/decks_dao_provider.dart';

part 'deck_list_controller.g.dart';

@riverpod
class DeckListController extends _$DeckListController {
  @override
  Stream<List<DeckWithCounts>> build() {
    final dao = ref.watch(decksDaoProvider);
    return dao.watchAllDecksWithCounts();
  }

  Future<void> createDeck({required String name, String? description}) async {
    final dao = ref.read(decksDaoProvider);
    await dao.createDeck(name: name, description: description);
  }

  Future<void> updateDeck({
    required int id,
    required String name,
    String? description,
  }) async {
    final dao = ref.read(decksDaoProvider);
    await dao.updateDeck(id: id, name: name, description: description);
  }

  Future<void> deleteDeck(int id) async {
    final dao = ref.read(decksDaoProvider);
    await dao.deleteDeck(id);
  }
}
