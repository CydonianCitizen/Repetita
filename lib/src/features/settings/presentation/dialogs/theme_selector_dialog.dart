import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/app_theme_mode.dart';
import '../controllers/theme_mode_controller.dart';

class ThemeSelectorDialog extends ConsumerWidget {
  const ThemeSelectorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const ThemeSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeControllerProvider);
    final l10n = AppLocalizations.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(l10n?.themeMode ?? 'Theme Mode'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                currentMode == AppThemeMode.system
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: currentMode == AppThemeMode.system ? primaryColor : null,
              ),
              title: Text(l10n?.themeSystem ?? 'System Default'),
              subtitle: Text(
                l10n?.themeModeSubtitle ?? 'Follow device theme settings',
              ),
              onTap: () {
                ref
                    .read(themeModeControllerProvider.notifier)
                    .setThemeMode(AppThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                currentMode == AppThemeMode.dark
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: currentMode == AppThemeMode.dark ? primaryColor : null,
              ),
              title: Text(l10n?.themeDark ?? 'Dark Theme'),
              subtitle: Text(
                l10n?.themeDarkSubtitle ?? 'Always use dark palette',
              ),
              onTap: () {
                ref
                    .read(themeModeControllerProvider.notifier)
                    .setThemeMode(AppThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                currentMode == AppThemeMode.amoled
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: currentMode == AppThemeMode.amoled ? primaryColor : null,
              ),
              title: Text(l10n?.themeAmoled ?? 'AMOLED (Pure Black)'),
              subtitle: Text(
                l10n?.themeAmoledSubtitle ??
                    'Optimized for OLED displays to save battery',
              ),
              onTap: () {
                ref
                    .read(themeModeControllerProvider.notifier)
                    .setThemeMode(AppThemeMode.amoled);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                currentMode == AppThemeMode.light
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: currentMode == AppThemeMode.light ? primaryColor : null,
              ),
              title: Text(l10n?.themeLight ?? 'Light Theme'),
              subtitle: Text(
                l10n?.themeLightSubtitle ?? 'Always use light palette',
              ),
              onTap: () {
                ref
                    .read(themeModeControllerProvider.notifier)
                    .setThemeMode(AppThemeMode.light);
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
