import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const int reminderNotificationId = 1001;
  static const int testNotificationId = 1002;

  static const String channelId = 'study_reminders';
  static const String channelName = 'Study Reminders';
  static const String channelDescription =
      'Daily spaced repetition study reminders for Repetita';

  Future<bool> initialize() async {
    if (_initialized) return true;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Repetita',
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Repetita',
      appUserModelId: 'com.repetita.app',
      guid: '8b555c78-4941-4daa-877f-24f8aa1a6bee',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    try {
      final success = await _plugin.initialize(settings: initSettings);
      _initialized = success ?? true;
      return _initialized;
    } catch (e) {
      debugPrint('NotificationService init error (handled): $e');
      if (e is MissingPluginException || (e is Error && e is! ArgumentError)) {
        _initialized = true;
        return true;
      }
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    await initialize();

    try {
      // Android 13+ POST_NOTIFICATIONS permission
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        return granted ?? false;
      }

      // iOS permissions
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImpl != null) {
        final granted = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      // macOS permissions
      final macosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      if (macosImpl != null) {
        final granted = await macosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Permission request exception: $e');
      if (e is MissingPluginException || (e is Error && e is! ArgumentError)) {
        return true;
      }
      return false;
    }
  }

  NotificationDetails _notificationDetails() {
    const darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const linux = LinuxNotificationDetails();
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      ),
      iOS: darwin,
      macOS: darwin,
      linux: linux,
    );
  }

  Future<bool> showTestNotification({
    required String title,
    required String body,
  }) async {
    final initOk = await initialize();
    if (!initOk) return false;
    try {
      await _plugin.show(
        id: testNotificationId,
        title: title,
        body: body,
        notificationDetails: _notificationDetails(),
      );
      return true;
    } catch (e) {
      debugPrint('showTestNotification error: $e');
      if (e is MissingPluginException || (e is Error && e is! ArgumentError)) {
        return true;
      }
      return false;
    }
  }

  Future<bool> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final initOk = await initialize();
    if (!initOk) return false;
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: reminderNotificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return true;
    } catch (e) {
      debugPrint('scheduleDailyReminder error: $e');
      if (e is MissingPluginException || (e is Error && e is! ArgumentError)) {
        return true;
      }
      return false;
    }
  }

  Future<bool> cancelReminder() async {
    try {
      await _plugin.cancel(id: reminderNotificationId);
      return true;
    } catch (e) {
      debugPrint('cancelReminder error: $e');
      if (e is MissingPluginException || (e is Error && e is! ArgumentError)) {
        return true;
      }
      return false;
    }
  }
}
