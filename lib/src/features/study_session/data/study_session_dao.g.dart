// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_dao.dart';

// ignore_for_file: type=lint
mixin _$StudySessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $DecksTable get decks => attachedDatabase.decks;
  $CardsTable get cards => attachedDatabase.cards;
  $ReviewLogsTable get reviewLogs => attachedDatabase.reviewLogs;
  StudySessionDaoManager get managers => StudySessionDaoManager(this);
}

class StudySessionDaoManager {
  final _$StudySessionDaoMixin _db;
  StudySessionDaoManager(this._db);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db.attachedDatabase, _db.decks);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db.attachedDatabase, _db.reviewLogs);
}
