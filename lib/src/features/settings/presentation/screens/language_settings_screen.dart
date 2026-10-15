import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../controllers/locale_controller.dart';
import '../widgets/section_header.dart';
import '../widgets/settings_card.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

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
    final colorScheme = Theme.of(context).colorScheme;

    final options = [
      _LanguageOption(
        locale: null,
        title: l10n?.themeSystem ?? 'System Default',
        subtitle:
            l10n?.systemLanguageSubtitle ?? 'Follow device system language',
        isSelected: currentLocale == null,
      ),
      _LanguageOption(
        locale: const Locale('en'),
        title: l10n?.english ?? 'English',
        subtitle: 'English (US)',
        isSelected: currentLocale?.languageCode == 'en',
      ),
      _LanguageOption(
        locale: const Locale('it'),
        title: l10n?.italian ?? 'Italiano',
        subtitle: 'Lingua italiana',
        isSelected: currentLocale?.languageCode == 'it',
      ),
      _LanguageOption(
        locale: const Locale('es'),
        title: l10n?.spanish ?? 'Español',
        subtitle: l10n?.comingSoon ?? 'Coming soon',
        isSelected: currentLocale?.languageCode == 'es',
        isPlaceholder: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.language ?? 'Language')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            SectionHeader(
              title: l10n?.sectionLanguage ?? 'LANGUAGE & LOCALIZATION',
            ),
            SettingsCard(
              children: [
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0) const Divider(indent: 56, height: 1),
                  ListTile(
                    leading: Icon(
                      options[i].isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: options[i].isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                    ),
                    title: Text(
                      options[i].title,
                      style: TextStyle(
                        fontWeight: options[i].isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      options[i].subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: options[i].isSelected
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n?.active ?? 'Active',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          )
                        : null,
                    onTap: () {
                      if (options[i].isPlaceholder) {
                        _showPlaceholderNotice(context, options[i].title);
                        return;
                      }
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(options[i].locale);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.locale,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    this.isPlaceholder = false,
  });

  final Locale? locale;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isPlaceholder;
}
