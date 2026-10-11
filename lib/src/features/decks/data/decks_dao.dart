import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/cards_table.dart';
import '../../../core/database/tables/decks_table.dart';

part 'decks_dao.g.dart';

class DeckWithCounts {
  const DeckWithCounts({
    required this.deck,
    required this.totalCards,
    required this.dueCards,
  });

  final Deck deck;
  final int totalCards;
  final int dueCards;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckWithCounts &&
          runtimeType == other.runtimeType &&
          deck == other.deck &&
          totalCards == other.totalCards &&
          dueCards == other.dueCards;

  @override
  int get hashCode => Object.hash(deck, totalCards, dueCards);
}

@DriftAccessor(tables: [Decks, Cards])
class DecksDao extends DatabaseAccessor<AppDatabase> with _$DecksDaoMixin {
  DecksDao(super.db);

  Stream<List<DeckWithCounts>> watchAllDecksWithCounts() {
    final totalCards = cards.id.count();
    final isDue =
        cards.id.isNotNull() &
        (cards.due.isSmallerOrEqual(currentDateAndTime) |
            cards.state.equals(0));
    final dueCards = isDue
        .caseMatch<int>(
          when: {const Constant(true): const Constant(1)},
          orElse: const Constant(0),
        )
        .sum();

    final query =
        select(decks)
            .join([leftOuterJoin(cards, cards.deckId.equalsExp(decks.id))])
          ..addColumns([totalCards, dueCards])
          ..groupBy([decks.id])
          ..orderBy([OrderingTerm.desc(decks.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return DeckWithCounts(
          deck: row.readTable(decks),
          totalCards: row.read(totalCards) ?? 0,
          dueCards: row.read(dueCards) ?? 0,
        );
      }).toList();
    });
  }

  Future<int> createDeck({required String name, String? description}) {
    final now = DateTime.now().toUtc();
    return into(decks).insert(
      DecksCompanion.insert(
        name: name.trim(),
        description: Value(description?.trim()),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<bool> updateDeck({
    required int id,
    required String name,
    String? description,
  }) {
    final now = DateTime.now().toUtc();
    return (update(decks)..where((t) => t.id.equals(id)))
        .write(
          DecksCompanion(
            name: Value(name.trim()),
            description: Value(description?.trim()),
            updatedAt: Value(now),
          ),
        )
        .then((rows) => rows > 0);
  }

  Future<int> deleteDeck(int id) {
    return (delete(decks)..where((t) => t.id.equals(id))).go();
  }
}
