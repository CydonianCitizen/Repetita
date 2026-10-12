import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/settings/data/notification_service.dart';
import 'package:repetita/src/features/settings/domain/reminder_settings.dart';
import 'package:repetita/src/features/settings/presentation/controllers/reminder_controller.dart';

class _FakeFailingNotificationService extends NotificationService {
  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<bool> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async => false;

  @override
  Future<bool> cancelReminder() async => false;

  @override
  Future<bool> showTestNotification({
    required String title,
    required String body,
  }) async => false;
}

void main() {
  group('ReminderSettings Unit Tests', () {
    test('defaults and formattedTime format properly', () {
      const defaultSettings = ReminderSettings();
      expect(defaultSettings.enabled, isFalse);
      expect(defaultSettings.hour, 20);
      expect(defaultSettings.minute, 0);
      expect(defaultSettings.formattedTime, '20:00');

      final custom = defaultSettings.copyWith(
        enabled: true,
        hour: 8,
        minute: 5,
      );
      expect(custom.enabled, isTrue);
      expect(custom.hour, 8);
      expect(custom.minute, 5);
      expect(custom.formattedTime, '08:05');
    });
  });

  group('NotificationService Unit Tests', () {
    test(
      'initializes and methods execute returning boolean status',
      () async {
        final service = NotificationService();
        // Should not throw in headless / unit test environment
        final initSuccess = await service.initialize();
        expect(initSuccess, isTrue);
        final cancelSuccess = await service.cancelReminder();
        expect(cancelSuccess, isTrue);
        final testSuccess = await service.showTestNotification(
          title: 'Test',
          body: 'Body',
        );
        expect(testSuccess, isTrue);
      },
    );

    test(
      'ReminderController.setEnabled throws and does NOT persist enabled=true when scheduling fails',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            notificationServiceProvider.overrideWithValue(
              _FakeFailingNotificationService(),
            ),
          ],
        );

        final controller = container.read(reminderControllerProvider.notifier);

        expect(
          () => controller.setEnabled(true, title: 'Title', body: 'Body'),
          throwsA(isA<Exception>()),
        );

        // State must remain false
        expect(container.read(reminderControllerProvider).enabled, isFalse);

        // Database setting must NOT be persisted as 'true'
        final persisted = await db.getSetting('reminder_enabled');
        expect(persisted, isNot(equals('true')));

        // Allow any pending async initialization to finish before closing
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await db.close();
        container.dispose();
      },
    );
  });
}
