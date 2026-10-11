import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/update_service.dart';
import '../../domain/update_info.dart';

part 'update_controller.g.dart';

@Riverpod(keepAlive: true)
UpdateService updateService(Ref ref) {
  return UpdateService();
}

@Riverpod(keepAlive: true)
class UpdateCheckController extends _$UpdateCheckController {
  @override
  AsyncValue<UpdateInfo?> build() => const AsyncData(null);

  Future<UpdateInfo?> checkForUpdates({required String currentVersion}) async {
    state = const AsyncLoading();
    final service = ref.read(updateServiceProvider);
    final result = await AsyncValue.guard(
      () => service.checkForUpdates(currentVersion: currentVersion),
    );
    if (ref.mounted) {
      state = result;
    }
    return result.value;
  }
}
