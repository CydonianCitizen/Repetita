// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_dao.dart';

// ignore_for_file: type=lint
mixin _$StatsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DecksTable get decks => attachedDatabase.decks;
  $CardsTable get cards => attachedDatabase.cards;
  $ReviewLogsTable get reviewLogs => attachedDatabase.reviewLogs;
  StatsDaoManager get managers => StatsDaoManager(this);
}

class StatsDaoManager {
  final _$StatsDaoMixin _db;
  StatsDaoManager(this._db);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db.attachedDatabase, _db.decks);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db.attachedDatabase, _db.reviewLogs);
}
