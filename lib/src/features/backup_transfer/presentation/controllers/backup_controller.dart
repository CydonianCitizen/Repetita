import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/backup_service_provider.dart';
import '../../domain/models/csv_card_row.dart';

part 'backup_controller.g.dart';

@riverpod
class BackupController extends _$BackupController {
  @override
  void build() {}

  Future<String> exportJson() async {
    final service = ref.read(backupServiceProvider);
    return service.exportJsonPayload();
  }

  Future<void> importJson(String jsonString) async {
    final service = ref.read(backupServiceProvider);
    await service.importJsonPayload(jsonString, replaceExisting: true);
  }

  Future<String> exportCsv({int? deckId}) async {
    final service = ref.read(backupServiceProvider);
    return service.exportCardsToCsv(deckId: deckId);
  }

  Future<CsvImportResult> importCsv(
    String csvString, {
    required int targetDeckId,
  }) async {
    final service = ref.read(backupServiceProvider);
    return service.importCardsFromCsv(csvString, targetDeckId: targetDeckId);
  }

  Future<CsvImportResult> importCardsFromCsv(
    String csvString, {
    required int targetDeckId,
  }) async {
    return importCsv(csvString, targetDeckId: targetDeckId);
  }
}
