import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_provider.dart';
import 'decks_dao.dart';

part 'decks_dao_provider.g.dart';

@riverpod
DecksDao decksDao(Ref ref) {
  final db = ref.watch(databaseProvider);
  return db.decksDao;
}
