import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/cards/data/cards_dao.dart';
import '../../features/decks/data/decks_dao.dart';
import '../../features/stats/data/stats_dao.dart';
import '../../features/study_session/data/study_session_dao.dart';
import 'tables/cards_table.dart';
import 'tables/decks_table.dart';
import 'tables/review_logs_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Decks, Cards, ReviewLogs],
  daos: [DecksDao, CardsDao, StudySessionDao, StatsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
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
