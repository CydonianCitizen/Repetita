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
import 'tables/cards_table.dart';
import 'tables/decks_table.dart';
import 'tables/review_logs_table.dart';
import 'tables/tags_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Decks, Cards, ReviewLogs, Tags, CardTags],
  daos: [DecksDao, CardsDao, StudySessionDao, StatsDao, TagsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

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
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'repetita.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
