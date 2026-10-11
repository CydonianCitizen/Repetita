import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../controllers/locale_controller.dart';

class LanguageSelectorDialog extends ConsumerWidget {
  const LanguageSelectorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }

  void _showPlaceholderNotice(BuildContext context, String feature) {
    final l10n = AppLocalizations.of(context);
    final message =
        l10n?.comingSoonNotice(feature) ??
        '$feature feature coming in an upcoming release!';

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    final l10n = AppLocalizations.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AlertDialog(
      title: Text(l10n?.selectLanguage ?? 'Select Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              currentLocale == null
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: currentLocale == null ? primaryColor : null,
            ),
            title: Text(l10n?.themeSystem ?? 'System Default'),
            subtitle: Text(
              l10n?.systemLanguageSubtitle ?? 'Follow device system language',
            ),
            onTap: () {
              ref.read(localeControllerProvider.notifier).setLocale(null);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(
              currentLocale?.languageCode == 'en'
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: currentLocale?.languageCode == 'en' ? primaryColor : null,
            ),
            title: Text(l10n?.english ?? 'English'),
            subtitle: Text(
              currentLocale?.languageCode == 'en'
                  ? (l10n?.active ?? 'Active')
                  : 'English (US)',
            ),
            onTap: () {
              ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(const Locale('en'));
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(
              currentLocale?.languageCode == 'it'
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: currentLocale?.languageCode == 'it' ? primaryColor : null,
            ),
            title: Text(l10n?.italian ?? 'Italiano'),
            subtitle: Text(
              currentLocale?.languageCode == 'it'
                  ? (l10n?.active ?? 'Attiva')
                  : 'Lingua italiana',
            ),
            onTap: () {
              ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(const Locale('it'));
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.radio_button_unchecked),
            title: Text(l10n?.spanish ?? 'Español'),
            subtitle: Text(l10n?.comingSoon ?? 'Coming soon'),
            onTap: () {
              Navigator.of(context).pop();
              _showPlaceholderNotice(context, 'Spanish translation');
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
