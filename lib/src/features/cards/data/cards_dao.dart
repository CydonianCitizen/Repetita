import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/cards_table.dart';
import '../domain/card_entity.dart';

part 'cards_dao.g.dart';

extension CardToEntity on Card {
  CardEntity toEntity() => CardEntity(
    id: id,
    deckId: deckId,
    front: front,
    back: back,
    state: state,
    stability: stability,
    difficulty: difficulty,
    due: due,
    lastReview: lastReview,
    reps: reps,
    lapses: lapses,
    createdAt: createdAt,
  );
}

@DriftAccessor(tables: [Cards])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  Stream<List<Card>> watchCardsByDeck(int deckId) {
    return (select(cards)
          ..where((t) => t.deckId.equals(deckId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Future<List<Card>> getCardsByDeck(int deckId) {
    return (select(cards)
          ..where((t) => t.deckId.equals(deckId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<List<Card>> getDueCards(int deckId, DateTime cutoff) {
    final cutoffUtc = cutoff.toUtc();
    return (select(cards)
          ..where(
            (t) =>
                t.deckId.equals(deckId) &
                (t.due.isSmallerOrEqualValue(cutoffUtc) | t.state.equals(0)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.due)]))
        .get();
  }

  Future<int> createCard({
    required int deckId,
    required String front,
    required String back,
  }) {
    final now = DateTime.now().toUtc();
    return into(cards).insert(
      CardsCompanion.insert(
        deckId: deckId,
        front: front.trim(),
        back: back.trim(),
        state: const Value(0),
        stability: const Value(0.0),
        difficulty: const Value(0.0),
        due: now,
        reps: const Value(0),
        lapses: const Value(0),
        createdAt: Value(now),
      ),
    );
  }

  Future<bool> updateCardContent({
    required int id,
    required String front,
    required String back,
  }) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(
          CardsCompanion(front: Value(front.trim()), back: Value(back.trim())),
        )
        .then((rows) => rows > 0);
  }

  Future<int> deleteCard(int id) {
    return (delete(cards)..where((t) => t.id.equals(id))).go();
  }
}
