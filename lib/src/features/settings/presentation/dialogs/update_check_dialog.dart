import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../data/update_service.dart';
import '../controllers/update_controller.dart';
import '../settings_screen.dart';

class UpdateCheckDialog extends ConsumerWidget {
  const UpdateCheckDialog({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) {
    ref
        .read(updateCheckControllerProvider.notifier)
        .checkForUpdates(currentVersion: SettingsScreen.appVersion);

    return showDialog<void>(
      context: context,
      builder: (context) => const UpdateCheckDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateCheckControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return updateState.when(
      loading: () => AlertDialog(
        title: Text(l10n?.checkForUpdates ?? 'Check for Updates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              l10n?.checkingForUpdates ?? 'Checking GitHub releases...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
      error: (err, stack) => AlertDialog(
        icon: Icon(Icons.cloud_off_rounded, size: 48, color: colorScheme.error),
        title: Text(l10n?.updateCheckFailed ?? 'Could not check for updates'),
        content: Text(
          err is UpdateCheckException
              ? err.message
              : (l10n?.updateCheckFailedDesc ??
                    'Please check your internet connection and try again.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
      data: (info) {
        if (info == null) {
          return AlertDialog(
            title: Text(l10n?.checkForUpdates ?? 'Check for Updates'),
            content: Text(
              l10n?.checkingForUpdates ?? 'Checking GitHub releases...',
            ),
          );
        }

        if (info.hasUpdate) {
          return AlertDialog(
            icon: Icon(
              Icons.new_releases_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
            title: Text(l10n?.updateAvailable ?? 'Update Available!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.updateAvailableDesc(info.latestVersion) ??
                      'A new version (${info.latestVersion}) is available on GitHub.',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Current: ${info.currentVersion} • Latest: ${info.latestVersion}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (info.releaseNotes != null &&
                    info.releaseNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Release Notes:',
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: SingleChildScrollView(
                      child: Text(
                        info.releaseNotes!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n?.close ?? 'Close'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Release URL: ${info.releaseUrl}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(l10n?.viewOnGitHub ?? 'View on GitHub'),
              ),
            ],
          );
        }

        return AlertDialog(
          icon: Icon(
            Icons.check_circle_outline_rounded,
            size: 48,
            color: colorScheme.primary,
          ),
          title: Text(l10n?.upToDate ?? 'Up to Date'),
          content: Text(
            l10n?.upToDateDesc(info.currentVersion) ??
                'repetita is currently running the latest version: ${info.currentVersion}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n?.ok ?? 'OK'),
            ),
          ],
        );
      },
    );
  }
}
