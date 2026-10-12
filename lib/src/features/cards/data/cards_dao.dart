import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
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
    due: due.toUtc(),
    lastReview: lastReview?.toUtc(),
    reps: reps,
    lapses: lapses,
    createdAt: createdAt.toUtc(),
    isSuspended: isSuspended,
    buriedUntil: buriedUntil?.toUtc(),
    clozeIndex: clozeIndex,
  );
}

@DriftAccessor(tables: [Cards])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(super.db);

  Stream<List<Card>> watchCardsByDeck(int deckId, {int? limit, int? offset}) {
    final query = select(cards)
      ..where((t) => t.deckId.equals(deckId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.watch();
  }

  Future<List<Card>> getCardsByDeck(int deckId, {int? limit, int? offset}) {
    final query = select(cards)
      ..where((t) => t.deckId.equals(deckId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAt),
        (t) => OrderingTerm.desc(t.id),
      ]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  static DateTime computeTomorrowMidnight([DateTime? now]) {
    final base = (now ?? DateTime.now()).toUtc().add(const Duration(days: 1));
    return DateTime.utc(base.year, base.month, base.day);
  }

  Future<int> createCard({
    required int deckId,
    required String front,
    required String back,
    int? clozeIndex,
    DateTime? now,
  }) {
    final effectiveNow = (now ?? DateTime.now()).toUtc();
    return into(cards).insert(
      CardsCompanion.insert(
        deckId: deckId,
        front: front.trim(),
        back: back.trim(),
        state: const Value(0),
        stability: const Value(0.0),
        difficulty: const Value(0.0),
        due: effectiveNow,
        reps: const Value(0),
        lapses: const Value(0),
        createdAt: Value(effectiveNow),
        isSuspended: const Value(false),
        clozeIndex: Value(clozeIndex),
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

  Future<bool> setCardSuspended(int id, bool isSuspended) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(CardsCompanion(isSuspended: Value(isSuspended)))
        .then((rows) => rows > 0);
  }

  Future<bool> _buryCard(int id, DateTime until) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(CardsCompanion(buriedUntil: Value(until.toUtc())))
        .then((rows) => rows > 0);
  }

  Future<bool> buryCardUntilTomorrow(int id, [DateTime? now]) {
    return _buryCard(id, computeTomorrowMidnight(now));
  }

  Future<bool> unburyCard(int id) {
    return (update(cards)..where((t) => t.id.equals(id)))
        .write(const CardsCompanion(buriedUntil: Value(null)))
        .then((rows) => rows > 0);
  }

  Future<int> deleteCard(int id) {
    return (delete(cards)..where((t) => t.id.equals(id))).go();
  }
}
