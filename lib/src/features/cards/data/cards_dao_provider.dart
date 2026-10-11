import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_provider.dart';
import 'cards_dao.dart';

part 'cards_dao_provider.g.dart';

@riverpod
CardsDao cardsDao(Ref ref) {
  final db = ref.watch(databaseProvider);
  return db.cardsDao;
}
