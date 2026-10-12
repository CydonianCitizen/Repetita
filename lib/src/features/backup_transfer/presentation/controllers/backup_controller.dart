import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/models/backup_payload.dart';

part 'backup_controller.g.dart';

@riverpod
class BackupController extends _$BackupController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String> exportJson() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.exportJsonPayload();
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> importJson(
    String jsonString, {
    bool replaceExisting = true,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(backupServiceProvider);
      await service.importJsonPayload(
        jsonString,
        replaceExisting: replaceExisting,
      );
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<String> exportCsv({int? deckId}) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.exportCardsToCsv(deckId: deckId);
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<CsvImportResult> importCsv(
    String csvString, {
    required int targetDeckId,
  }) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.importCardsFromCsv(
        csvString,
        targetDeckId: targetDeckId,
      );
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
