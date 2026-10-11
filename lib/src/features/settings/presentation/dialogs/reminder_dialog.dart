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

    return AlertDialog(
      title: Text(l10n?.studyReminders ?? 'Study Reminders'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                await ref
                    .read(reminderControllerProvider.notifier)
                    .setEnabled(
                      enabled,
                      title:
                          l10n?.notificationTitle ??
                          'Time to review with repetita!',
                      body: l10n?.notificationBody ?? 'You have spaced repetition flashcards due for review today.',
                    );
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
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              key: const Key('send_test_notification_button'),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(l10n?.testNotification ?? 'Send Test Notification'),
              onPressed: () async {
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
              },
            ),
          ],
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
