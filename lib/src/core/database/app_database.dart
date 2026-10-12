import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/cards/data/cards_dao.dart';
import '../../features/decks/data/decks_dao.dart';
import '../../features/stats/data/stats_dao.dart';
import '../../features/study_session/data/study_session_dao.dart';
import '../../features/tags/data/tags_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Decks, Cards, ReviewLogs, Tags, CardTags, AppSettings],
  daos: [DecksDao, CardsDao, StudySessionDao, StatsDao, TagsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(cards, cards.isSuspended);
          await m.addColumn(cards, cards.buriedUntil);
        }
        if (from < 3) {
          await m.addColumn(cards, cards.clozeIndex);
          await m.createTable(tags);
          await m.createTable(cardTags);
        }
        if (from < 4) {
          await m.createTable(appSettings);
        }
        if (from < 5) {
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_cards_deck_id ON cards (deck_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_cards_due ON cards (due)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_review_logs_card_id ON review_logs (card_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_review_logs_reviewed_at ON review_logs (reviewed_at)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_card_tags_tag_id ON card_tags (tag_id)',
          );
        }
      },
    );
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Stream<String?> watchSetting(String key) {
    return (select(appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'repetita.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
