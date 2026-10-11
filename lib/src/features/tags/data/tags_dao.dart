import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/cards_table.dart';
import '../../../core/database/tables/tags_table.dart';
import '../domain/tag_entity.dart';

part 'tags_dao.g.dart';

extension TagToEntity on Tag {
  TagEntity toEntity() =>
      TagEntity(id: id, name: name, color: color, createdAt: createdAt);
}

@DriftAccessor(tables: [Tags, CardTags, Cards])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  Stream<List<Tag>> watchAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<List<Tag>> getAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<int> getOrCreateTag(String name, {int color = 0}) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return 0;

    final existing = await (select(
      tags,
    )..where((t) => t.name.equals(cleanName))).getSingleOrNull();

    if (existing != null) {
      return existing.id;
    }

    return into(tags)
        .insert(TagsCompanion.insert(name: cleanName, color: Value(color)));
  }

  Future<bool> deleteTag(int tagId) {
    return (delete(
      tags,
    )..where((t) => t.id.equals(tagId))).go().then((rows) => rows > 0);
  }

  Future<void> setCardTags(int cardId, List<int> tagIds) async {
    await transaction(() async {
      await (delete(cardTags)..where((t) => t.cardId.equals(cardId))).go();
      for (final tagId in tagIds) {
        await into(cardTags).insert(
          CardTagsCompanion.insert(cardId: cardId, tagId: tagId),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Stream<List<Tag>> watchTagsForCard(int cardId) {
    final query =
        select(tags)
            .join([innerJoin(cardTags, cardTags.tagId.equalsExp(tags.id))])
          ..where(cardTags.cardId.equals(cardId))
          ..orderBy([OrderingTerm.asc(tags.name)]);

    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(tags)).toList(),
    );
  }

  Future<List<Tag>> getTagsForCard(int cardId) {
    final query =
        select(tags)
            .join([innerJoin(cardTags, cardTags.tagId.equalsExp(tags.id))])
          ..where(cardTags.cardId.equals(cardId))
          ..orderBy([OrderingTerm.asc(tags.name)]);

    return query.get().then(
      (rows) => rows.map((r) => r.readTable(tags)).toList(),
    );
  }

  Stream<Map<int, List<Tag>>> watchTagsForDeck(int deckId) {
    final query =
        select(tags).join([
            innerJoin(cardTags, cardTags.tagId.equalsExp(tags.id)),
            innerJoin(cards, cards.id.equalsExp(cardTags.cardId)),
          ])
          ..where(cards.deckId.equals(deckId))
          ..orderBy([OrderingTerm.asc(tags.name)]);

    return query.watch().map((rows) {
      final map = <int, List<Tag>>{};
      for (final row in rows) {
        final cardTag = row.readTable(cardTags);
        final tag = row.readTable(tags);
        map.putIfAbsent(cardTag.cardId, () => []).add(tag);
      }
      return map;
    });
  }

  Stream<List<Card>> watchCardsByDeckFiltered(int deckId, {int? filterTagId}) {
    if (filterTagId == null) {
      return (select(cards)
            ..where((t) => t.deckId.equals(deckId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();
    }

    final query =
        select(cards)
            .join([innerJoin(cardTags, cardTags.cardId.equalsExp(cards.id))])
          ..where(
            cards.deckId.equals(deckId) & cardTags.tagId.equals(filterTagId),
          )
          ..orderBy([
            OrderingTerm.desc(cards.createdAt),
            OrderingTerm.desc(cards.id),
          ]);

    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(cards)).toList(),
    );
  }
}
