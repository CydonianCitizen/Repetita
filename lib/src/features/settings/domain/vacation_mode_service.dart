import '../../../core/database/app_database.dart';

class VacationModeService {
  VacationModeService(this.db);

  final AppDatabase db;

  static const String _keyVacationActive = 'vacation_mode_active';
  static const String _keyVacationStart = 'vacation_start_timestamp';

  Future<bool> isVacationActive() async {
    final val = await db.getSetting(_keyVacationActive);
    return val == 'true';
  }

  Future<DateTime?> getVacationStartDate() async {
    final val = await db.getSetting(_keyVacationStart);
    if (val == null) return null;
    return DateTime.tryParse(val)?.toUtc();
  }

  Future<void> startVacation([DateTime? startDate]) async {
    final effectiveStart = (startDate ?? DateTime.now()).toUtc();
    await db.setSetting(_keyVacationActive, 'true');
    await db.setSetting(_keyVacationStart, effectiveStart.toIso8601String());
  }

  Future<int> endVacation({DateTime? resumeDate}) async {
    final isActive = await isVacationActive();
    if (!isActive) return 0;

    final start = await getVacationStartDate();
    final effectiveResume = (resumeDate ?? DateTime.now()).toUtc();

    int days = 0;
    if (start != null) {
      days = effectiveResume.difference(start).inDays;
    }

    int shiftedCount = 0;
    if (days > 0) {
      shiftedCount = await db.cardsDao.shiftDueDatesForVacation(days);
    }

    await db.setSetting(_keyVacationActive, 'false');
    await db.setSetting(_keyVacationStart, '');
    return shiftedCount;
  }
}
