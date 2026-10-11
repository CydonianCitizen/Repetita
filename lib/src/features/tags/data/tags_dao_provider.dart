import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/database_provider.dart';
import 'tags_dao.dart';

part 'tags_dao_provider.g.dart';

@Riverpod(keepAlive: true)
TagsDao tagsDao(Ref ref) {
  final db = ref.watch(databaseProvider);
  return db.tagsDao;
}
