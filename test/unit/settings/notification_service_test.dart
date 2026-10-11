import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/settings/data/notification_service.dart';
import 'package:repetita/src/features/settings/domain/reminder_settings.dart';

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
      'initializes and methods execute without throwing unhandled exceptions',
      () async {
        final service = NotificationService();
        // Should not throw in headless / unit test environment
        await service.initialize();
        await service.cancelReminder();
        await service.showTestNotification(title: 'Test', body: 'Body');
      },
    );
  });
}
