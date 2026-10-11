import 'package:drift/drift.dart';

import 'decks_table.dart';

class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId =>
      integer().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get front => text()();
  TextColumn get back => text()();
  IntColumn get state => integer().withDefault(const Constant(0))();
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  DateTimeColumn get due => dateTime()();
  DateTimeColumn get lastReview => dateTime().nullable()();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSuspended => boolean().withDefault(const Constant(false))();
  DateTimeColumn get buriedUntil => dateTime().nullable()();
}
