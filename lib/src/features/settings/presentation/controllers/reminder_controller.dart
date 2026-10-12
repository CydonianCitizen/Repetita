import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/notification_service.dart';
import '../../domain/reminder_settings.dart';

part 'reminder_controller.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

@Riverpod(keepAlive: true)
class ReminderController extends _$ReminderController {
  static const _keyEnabled = 'reminder_enabled';
  static const _keyHour = 'reminder_hour';
  static const _keyMinute = 'reminder_minute';

  @override
  ReminderSettings build() {
    _loadPersistedSettings();
    return const ReminderSettings();
  }

  Future<void> _loadPersistedSettings() async {
    final db = ref.read(databaseProvider);
    final enabledStr = await db.getSetting(_keyEnabled);
    final hourStr = await db.getSetting(_keyHour);
    final minuteStr = await db.getSetting(_keyMinute);

    if (enabledStr == null && hourStr == null && minuteStr == null) {
      return;
    }

    final enabled = enabledStr == 'true';
    final hour = hourStr != null ? int.tryParse(hourStr) ?? 20 : 20;
    final minute = minuteStr != null ? int.tryParse(minuteStr) ?? 0 : 0;

    state = ReminderSettings(enabled: enabled, hour: hour, minute: minute);
  }

  Future<void> setEnabled(
    bool enabled, {
    required String title,
    required String body,
  }) async {
    final service = ref.read(notificationServiceProvider);
    if (enabled) {
      final granted = await service.requestPermissions();
      if (!granted) {
        throw Exception('Notification permission denied');
      }
      final success = await service.scheduleDailyReminder(
        hour: state.hour,
        minute: state.minute,
        title: title,
        body: body,
      );
      if (!success) {
        throw Exception('Failed to schedule daily reminder');
      }
    } else {
      await service.cancelReminder();
    }
    state = state.copyWith(enabled: enabled);
    final db = ref.read(databaseProvider);
    await db.setSetting(_keyEnabled, enabled.toString());
  }

  Future<void> setTime({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final service = ref.read(notificationServiceProvider);
    if (state.enabled) {
      final success = await service.scheduleDailyReminder(
        hour: hour,
        minute: minute,
        title: title,
        body: body,
      );
      if (!success) {
        throw Exception('Failed to schedule daily reminder');
      }
    }
    state = state.copyWith(hour: hour, minute: minute);
    final db = ref.read(databaseProvider);
    await db.setSetting(_keyHour, hour.toString());
    await db.setSetting(_keyMinute, minute.toString());

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
    final granted = await service.requestPermissions();
    if (!granted) {
      throw Exception('Notification permission denied');
    }
    await service.showTestNotification(title: title, body: body);
  }
}
