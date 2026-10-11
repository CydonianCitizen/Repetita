import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import 'study_session_dao.dart';

final studySessionDaoProvider = Provider<StudySessionDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.studySessionDao;
});
