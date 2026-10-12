import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/backup_payload.dart';

class BackupService {
  const BackupService(this.db);

  final AppDatabase db;

  Future<String> exportJsonPayload() async {
    final results = await Future.wait([
      db.select(db.decks).get(),
      db.select(db.cards).get(),
      db.select(db.reviewLogs).get(),
      db.select(db.tags).get(),
      db.select(db.cardTags).get(),
    ]);

    final decksList = results[0] as List<Deck>;
    final cardsList = results[1] as List<Card>;
    final reviewLogsList = results[2] as List<ReviewLog>;
    final tagsList = results[3] as List<Tag>;
    final cardTagsList = results[4] as List<CardTag>;

    final payload = BackupPayload(
      version: 1,
      exportedAt: DateTime.now().toUtc(),
      decks: decksList
          .map(
            (d) => DeckPayload(
              id: d.id,
              name: d.name,
              description: d.description,
              createdAt: d.createdAt,
              updatedAt: d.updatedAt,
            ),
          )
          .toList(),
      cards: cardsList
          .map(
            (c) => CardPayload(
              id: c.id,
              deckId: c.deckId,
              front: c.front,
              back: c.back,
              state: c.state,
              stability: c.stability,
              difficulty: c.difficulty,
              due: c.due,
              lastReview: c.lastReview,
              reps: c.reps,
              lapses: c.lapses,
              createdAt: c.createdAt,
              isSuspended: c.isSuspended,
              buriedUntil: c.buriedUntil,
              clozeIndex: c.clozeIndex,
            ),
          )
          .toList(),
      reviewLogs: reviewLogsList
          .map(
            (r) => ReviewLogPayload(
              id: r.id,
              cardId: r.cardId,
              rating: r.rating,
              state: r.state,
              due: r.due,
              stability: r.stability,
              difficulty: r.difficulty,
              elapsedDays: r.elapsedDays,
              lastElapsedDays: r.lastElapsedDays,
              scheduledDays: r.scheduledDays,
              reviewedAt: r.reviewedAt,
            ),
          )
          .toList(),
      tags: tagsList
          .map(
            (t) => TagPayload(
              id: t.id,
              name: t.name,
              color: t.color,
              createdAt: t.createdAt,
            ),
          )
          .toList(),
      cardTags: cardTagsList
          .map((ct) => CardTagPayload(cardId: ct.cardId, tagId: ct.tagId))
          .toList(),
    );

    return const JsonEncoder.withIndent('  ').convert(payload.toJson());
  }

  Future<void> importJsonPayload(
    String jsonString, {
    bool replaceExisting = true,
  }) async {
    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }

    final payload = BackupPayload.fromJson(decoded);

    await db.transaction(() async {
      if (replaceExisting) {
        await db.delete(db.cardTags).go();
        await db.delete(db.tags).go();
        await db.delete(db.reviewLogs).go();
        await db.delete(db.cards).go();
        await db.delete(db.decks).go();
      }

      final deckIdMap = <int, int>{};
      for (final deck in payload.decks) {
        final newDeckId = await db
            .into(db.decks)
            .insert(
              DecksCompanion.insert(
                name: deck.name,
                description: Value(deck.description),
                createdAt: Value(deck.createdAt),
                updatedAt: Value(deck.updatedAt),
              ),
            );
        deckIdMap[deck.id] = newDeckId;
      }

      final cardIdMap = <int, int>{};
      for (final card in payload.cards) {
        final targetDeckId = deckIdMap[card.deckId] ?? card.deckId;
        final newCardId = await db
            .into(db.cards)
            .insert(
              CardsCompanion.insert(
                deckId: targetDeckId,
                front: card.front,
                back: card.back,
                state: Value(card.state),
                stability: Value(card.stability),
                difficulty: Value(card.difficulty),
                due: card.due,
                lastReview: Value(card.lastReview),
                reps: Value(card.reps),
                lapses: Value(card.lapses),
                createdAt: Value(card.createdAt),
                isSuspended: Value(card.isSuspended),
                buriedUntil: Value(card.buriedUntil),
                clozeIndex: Value(card.clozeIndex),
              ),
            );
        cardIdMap[card.id] = newCardId;
      }

      for (final log in payload.reviewLogs) {
        final targetCardId = cardIdMap[log.cardId] ?? log.cardId;
        await db
            .into(db.reviewLogs)
            .insert(
              ReviewLogsCompanion.insert(
                cardId: targetCardId,
                rating: log.rating,
                state: log.state,
                due: log.due,
                stability: log.stability,
                difficulty: log.difficulty,
                elapsedDays: log.elapsedDays,
                lastElapsedDays: log.lastElapsedDays,
                scheduledDays: log.scheduledDays,
                reviewedAt: log.reviewedAt,
              ),
            );
      }

      final tagIdMap = <int, int>{};
      for (final tag in payload.tags) {
        final existingTag = await (db.select(
          db.tags,
        )..where((t) => t.name.equals(tag.name))).getSingleOrNull();
        final int targetTagId;
        if (existingTag != null) {
          targetTagId = existingTag.id;
        } else {
          targetTagId = await db
              .into(db.tags)
              .insert(
                TagsCompanion.insert(
                  name: tag.name,
                  color: Value(tag.color),
                  createdAt: Value(tag.createdAt),
                ),
              );
        }
        tagIdMap[tag.id] = targetTagId;
      }

      for (final ct in payload.cardTags) {
        final newCardId = cardIdMap[ct.cardId];
        final newTagId = tagIdMap[ct.tagId];
        if (newCardId != null && newTagId != null) {
          await db
              .into(db.cardTags)
              .insert(
                CardTagsCompanion.insert(cardId: newCardId, tagId: newTagId),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    });
  }

  Future<String> exportCardsToCsv({int? deckId}) async {
    final query = db.select(db.cards).join([
      innerJoin(db.decks, db.decks.id.equalsExp(db.cards.deckId)),
    ]);

    if (deckId != null) {
      query.where(db.cards.deckId.equals(deckId));
    }

    final rows = await query.get();
    final csvData = <List<dynamic>>[
      ['Front', 'Back', 'DeckName'],
      for (final row in rows)
        [
          row.readTable(db.cards).front,
          row.readTable(db.cards).back,
          row.readTable(db.decks).name,
        ],
    ];

    return csv.encode(csvData);
  }

  Future<CsvImportResult> importCardsFromCsv(
    String csvString, {
    required int targetDeckId,
  }) async {
    final parsedRows = csv.decode(csvString);

    if (parsedRows.isEmpty) {
      return const CsvImportResult(importedCount: 0, skippedCount: 0);
    }

    int importedCount = 0;
    int skippedCount = 0;

    int startIndex = 0;
    final firstRow = parsedRows.first;
    if (firstRow.isNotEmpty &&
        firstRow[0].toString().trim().toLowerCase() == 'front') {
      startIndex = 1;
    }

    final now = DateTime.now().toUtc();

    final companions = <CardsCompanion>[];
    for (int i = startIndex; i < parsedRows.length; i++) {
      final row = parsedRows[i];
      if (row.length < 2) {
        skippedCount++;
        continue;
      }

      final front = row[0].toString().trim();
      final back = row[1].toString().trim();

      if (front.isEmpty || back.isEmpty) {
        skippedCount++;
        continue;
      }

      companions.add(
        CardsCompanion.insert(
          deckId: targetDeckId,
          front: front,
          back: back,
          state: const Value(0),
          stability: const Value(0.0),
          difficulty: const Value(0.0),
          due: now,
          reps: const Value(0),
          lapses: const Value(0),
          createdAt: Value(now),
        ),
      );
      importedCount++;
    }

    if (companions.isNotEmpty) {
      await db.transaction(() async {
        for (final comp in companions) {
          await db.into(db.cards).insert(comp);
        }
      });
    }

    return CsvImportResult(
      importedCount: importedCount,
      skippedCount: skippedCount,
    );
  }
}
