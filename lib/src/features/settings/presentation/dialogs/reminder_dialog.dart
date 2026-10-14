import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../controllers/reminder_controller.dart';

class ReminderDialog extends ConsumerWidget {
  const ReminderDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const ReminderDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(reminderControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

    return AlertDialog(
      title: isDesktop
          ? Row(
              children: [
                Icon(
                  Icons.desktop_windows_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n?.desktopNotifications ?? 'Desktop Notifications',
                  ),
                ),
              ],
            )
          : Text(l10n?.studyReminders ?? 'Study Reminders'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isDesktop ? 480 : 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop) ...[
                // Desktop informative callout banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n?.desktopNotificationsExplanation ?? 'On Windows and macOS, notifications are active while the application is running. Fixed-time daily alarms cannot trigger when the application is closed.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  key: const Key('reminder_switch'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n?.desktopNotifications ?? 'Desktop Notifications',
                  ),
                  subtitle: Text(
                    reminder.enabled
                        ? (l10n?.desktopNotificationsActive ??
                              'System notifications enabled')
                        : (l10n?.desktopNotificationsDisabled ??
                              'System notifications disabled'),
                  ),
                  value: reminder.enabled,
                  onChanged: (enabled) async {
                    try {
                      await ref
                          .read(reminderControllerProvider.notifier)
                          .setEnabled(
                            enabled,
                            title:
                                l10n?.notificationTitle ??
                                'Time to review with repetita!',
                            body: l10n?.notificationBody ?? 'You have spaced repetition flashcards due for review today.',
                          );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 8),
                // Desktop integration badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        defaultTargetPlatform == TargetPlatform.windows
                            ? Icons.laptop_windows_rounded
                            : (defaultTargetPlatform == TargetPlatform.macOS
                                  ? Icons.laptop_mac_rounded
                                  : Icons.laptop_chromebook_rounded),
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n?.systemIntegration(
                                defaultTargetPlatform == TargetPlatform.windows
                                    ? 'Windows'
                                    : (defaultTargetPlatform ==
                                              TargetPlatform.macOS
                                          ? 'macOS'
                                          : 'Linux'),
                              ) ??
                              'System integration: ${defaultTargetPlatform.name}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: reminder.enabled
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          reminder.enabled
                              ? (l10n?.active ?? 'Active')
                              : (l10n?.remindersOff ?? 'Off'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: reminder.enabled
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Mobile layout with time picker
                SwitchListTile(
                  key: const Key('reminder_switch'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n?.enableReminders ?? 'Daily Study Reminders'),
                  subtitle: Text(
                    reminder.enabled
                        ? '${reminder.formattedTime} - Active'
                        : (l10n?.remindersOff ?? 'Off'),
                  ),
                  value: reminder.enabled,
                  onChanged: (enabled) async {
                    try {
                      await ref
                          .read(reminderControllerProvider.notifier)
                          .setEnabled(
                            enabled,
                            title:
                                l10n?.notificationTitle ??
                                'Time to review with repetita!',
                            body: l10n?.notificationBody ?? 'You have spaced repetition flashcards due for review today.',
                          );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
                if (reminder.enabled) ...[
                  const Divider(height: 16),
                  ListTile(
                    key: const Key('reminder_time_tile'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time_rounded),
                    title: Text(l10n?.reminderTime ?? 'Reminder Time'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reminder.formattedTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: reminder.hour,
                          minute: reminder.minute,
                        ),
                      );
                      if (picked != null) {
                        await ref
                            .read(reminderControllerProvider.notifier)
                            .setTime(
                              hour: picked.hour,
                              minute: picked.minute,
                              title:
                                  l10n?.notificationTitle ??
                                  'Time to review with repetita!',
                              body: l10n?.notificationBody ?? 'You have spaced repetition flashcards due for review today.',
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n?.reminderDesc ?? 'Receive a gentle reminder each day to keep your review streak active.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                key: const Key('send_test_notification_button'),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(l10n?.testNotification ?? 'Send Test Notification'),
                onPressed: () async {
                  try {
                    await ref
                        .read(reminderControllerProvider.notifier)
                        .sendTestNotification(
                          title:
                              l10n?.notificationTitle ??
                              'Time to review with repetita!',
                          body: l10n?.notificationBody ?? 'You have spaced repetition flashcards due for review today.',
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n?.notificationSent ??
                                'Test notification dispatched!',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.close ?? 'Close'),
        ),
      ],
    );
  }
}
