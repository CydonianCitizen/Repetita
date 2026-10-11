import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/models/backup_payload.dart';
import '../../domain/models/csv_card_row.dart';

class BackupService {
  const BackupService(this.db);

  final AppDatabase db;

  Future<String> exportJsonPayload() async {
    final decksList = await db.select(db.decks).get();
    final cardsList = await db.select(db.cards).get();
    final reviewLogsList = await db.select(db.reviewLogs).get();

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

    final buffer = StringBuffer();
    buffer.writeln('Front,Back,DeckName');

    for (final row in rows) {
      final card = row.readTable(db.cards);
      final deck = row.readTable(db.decks);

      final frontEscaped = _escapeCsvField(card.front);
      final backEscaped = _escapeCsvField(card.back);
      final deckNameEscaped = _escapeCsvField(deck.name);

      buffer.writeln('$frontEscaped,$backEscaped,$deckNameEscaped');
    }

    return buffer.toString();
  }

  Future<CsvImportResult> importCardsFromCsv(
    String csvString, {
    required int targetDeckId,
  }) async {
    final parsedRows = _parseCsv(csvString);
    if (parsedRows.isEmpty) {
      return const CsvImportResult(importedCount: 0, skippedCount: 0);
    }

    int importedCount = 0;
    int skippedCount = 0;

    int startIndex = 0;
    final firstRow = parsedRows.first;
    if (firstRow.isNotEmpty && firstRow[0].trim().toLowerCase() == 'front') {
      startIndex = 1;
    }

    final now = DateTime.now().toUtc();

    for (int i = startIndex; i < parsedRows.length; i++) {
      final row = parsedRows[i];
      if (row.length < 2) {
        skippedCount++;
        continue;
      }

      final front = row[0].trim();
      final back = row[1].trim();

      if (front.isEmpty || back.isEmpty) {
        skippedCount++;
        continue;
      }

      await db
          .into(db.cards)
          .insert(
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

    return CsvImportResult(
      importedCount: importedCount,
      skippedCount: skippedCount,
    );
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r')) {
      final escaped = field.replaceAll('"', '""');
      return '"$escaped"';
    }
    return field;
  }

  List<List<String>> _parseCsv(String input) {
    final rows = <List<String>>[];
    final currentField = StringBuffer();
    final currentRow = <String>[];
    bool inQuotes = false;
    int i = 0;

    while (i < input.length) {
      final char = input[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < input.length && input[i + 1] == '"') {
            currentField.write('"');
            i += 2;
            continue;
          } else {
            inQuotes = false;
            i++;
            continue;
          }
        } else {
          currentField.write(char);
          i++;
          continue;
        }
      } else {
        if (char == '"') {
          inQuotes = true;
          i++;
          continue;
        } else if (char == ',') {
          currentRow.add(currentField.toString());
          currentField.clear();
          i++;
          continue;
        } else if (char == '\r') {
          if (i + 1 < input.length && input[i + 1] == '\n') {
            i++;
          }
          currentRow.add(currentField.toString());
          currentField.clear();
          rows.add(List.from(currentRow));
          currentRow.clear();
          i++;
          continue;
        } else if (char == '\n') {
          currentRow.add(currentField.toString());
          currentField.clear();
          rows.add(List.from(currentRow));
          currentRow.clear();
          i++;
          continue;
        } else {
          currentField.write(char);
          i++;
          continue;
        }
      }
    }

    if (currentField.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentField.toString());
      rows.add(currentRow);
    }

    return rows;
  }
}
