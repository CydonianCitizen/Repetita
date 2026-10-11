import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/notification_service.dart';
import '../../domain/reminder_settings.dart';

part 'reminder_controller.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

@Riverpod(keepAlive: true)
class ReminderController extends _$ReminderController {
  @override
  ReminderSettings build() => const ReminderSettings();

  Future<void> setEnabled(
    bool enabled, {
    required String title,
    required String body,
  }) async {
    final service = ref.read(notificationServiceProvider);
    if (enabled) {
      await service.requestPermissions();
      await service.scheduleDailyReminder(
        hour: state.hour,
        minute: state.minute,
        title: title,
        body: body,
      );
    } else {
      await service.cancelReminder();
    }
    state = state.copyWith(enabled: enabled);
  }

  Future<void> setTime({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    state = state.copyWith(hour: hour, minute: minute);
    if (state.enabled) {
      final service = ref.read(notificationServiceProvider);
      await service.scheduleDailyReminder(
        hour: hour,
        minute: minute,
        title: title,
        body: body,
      );
    }
  }

  Future<void> sendTestNotification({
    required String title,
    required String body,
  }) async {
    final service = ref.read(notificationServiceProvider);
    await service.requestPermissions();
    await service.showTestNotification(title: title, body: body);
  }
}
