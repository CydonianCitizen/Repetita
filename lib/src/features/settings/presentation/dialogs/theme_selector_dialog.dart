import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              currentMode == ThemeMode.system
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: currentMode == ThemeMode.system ? primaryColor : null,
            ),
            title: Text(l10n?.themeSystem ?? 'System Default'),
            subtitle: Text(
              l10n?.themeModeSubtitle ?? 'Follow device theme settings',
            ),
            onTap: () {
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setThemeMode(ThemeMode.system);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(
              currentMode == ThemeMode.dark
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: currentMode == ThemeMode.dark ? primaryColor : null,
            ),
            title: Text(l10n?.themeDark ?? 'Dark Theme'),
            subtitle: const Text('Always use dark palette'),
            onTap: () {
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setThemeMode(ThemeMode.dark);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(
              currentMode == ThemeMode.light
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: currentMode == ThemeMode.light ? primaryColor : null,
            ),
            title: Text(l10n?.themeLight ?? 'Light Theme'),
            subtitle: const Text('Always use light palette'),
            onTap: () {
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setThemeMode(ThemeMode.light);
              Navigator.of(context).pop();
            },
          ),
        ],
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
