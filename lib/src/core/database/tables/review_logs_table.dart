import 'package:drift/drift.dart';

import 'cards_table.dart';

class ReviewLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId =>
      integer().references(Cards, #id, onDelete: KeyAction.cascade)();
  IntColumn get rating => integer()();
  IntColumn get state => integer()();
  DateTimeColumn get due => dateTime()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
  IntColumn get elapsedDays => integer()();
  IntColumn get lastElapsedDays => integer()();
  IntColumn get scheduledDays => integer()();
  DateTimeColumn get reviewedAt => dateTime()();
}
