import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/refresh_rate_preference.dart';
import '../controllers/refresh_rate_controller.dart';

class RefreshRateDialog extends ConsumerWidget {
  const RefreshRateDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const RefreshRateDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPref = ref.watch(refreshRateControllerProvider);
    final l10n = AppLocalizations.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(l10n?.refreshRate ?? 'Refresh Rate'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                currentPref == RefreshRatePreference.system
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: currentPref == RefreshRatePreference.system
                    ? primaryColor
                    : null,
              ),
              title: Text(l10n?.refreshRateAuto ?? 'System Default (Dynamic)'),
              subtitle: Text(
                l10n?.refreshRateAutoDesc ??
                    'Adaptive refresh rate managed by Android OS',
              ),
              onTap: () {
                ref
                    .read(refreshRateControllerProvider.notifier)
                    .setPreference(RefreshRatePreference.system);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                currentPref == RefreshRatePreference.powerSave
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: currentPref == RefreshRatePreference.powerSave
                    ? primaryColor
                    : null,
              ),
              title: Text(
                l10n?.refreshRatePowerSave ?? 'Battery Saver (60 Hz)',
              ),
              subtitle: Text(
                l10n?.refreshRatePowerSaveDesc ??
                    'Fixed 60 Hz to minimize GPU power consumption',
              ),
              onTap: () {
                ref
                    .read(refreshRateControllerProvider.notifier)
                    .setPreference(RefreshRatePreference.powerSave);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                currentPref == RefreshRatePreference.high
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: currentPref == RefreshRatePreference.high
                    ? primaryColor
                    : null,
              ),
              title: Text(
                l10n?.refreshRateHigh ?? 'Maximum Fluidity (90/120 Hz)',
              ),
              subtitle: Text(
                l10n?.refreshRateHighDesc ??
                    'Highest supported refresh rate for silky-smooth motion',
              ),
              onTap: () {
                ref
                    .read(refreshRateControllerProvider.notifier)
                    .setPreference(RefreshRatePreference.high);
                Navigator.of(context).pop();
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
