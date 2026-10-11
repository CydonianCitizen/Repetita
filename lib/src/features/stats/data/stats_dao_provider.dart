import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import 'stats_dao.dart';

final statsDaoProvider = Provider<StatsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.statsDao;
});
