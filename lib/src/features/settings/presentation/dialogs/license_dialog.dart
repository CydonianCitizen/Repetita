import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../settings_screen.dart';

class LicenseDialog extends StatelessWidget {
  const LicenseDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const LicenseDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.licenseDialogTitle ?? 'MIT License'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n?.licenseCopyright ?? 'Copyright (c) 2026 repetita',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'Permission is hereby granted, free of charge, to any person obtaining a copy '
                'of this software and associated documentation files (the "Software"), to deal '
                'in the Software without restriction, including without limitation the rights '
                'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
                'copies of the Software, and to permit persons to whom the Software is '
                'furnished to do so, subject to the following conditions:\n\n'
                'The above copyright notice and this permission notice shall be included in all '
                'copies or substantial portions of the Software.\n\n'
                'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
                'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
                'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
                'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
                'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
                'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE '
                'SOFTWARE.',
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              key: const Key('view_all_licenses_button'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              icon: const Icon(Icons.policy_outlined, size: 18),
              label: Text(
                l10n?.viewAllLicenses ?? 'View All Open Source Licenses',
              ),
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationName: l10n?.appTitle ?? 'repetita',
                  applicationVersion: SettingsScreen.appVersion,
                  applicationLegalese:
                      'Copyright (c) 2026 repetita\nMIT License',
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'License: https://github.com/CydonianCitizen/Repetita/blob/main/LICENSE',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Text(l10n?.viewOnGitHub ?? 'View on GitHub'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.close ?? 'Close'),
        ),
      ],
    );
  }
}
