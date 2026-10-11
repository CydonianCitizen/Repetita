import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../domain/animation_level.dart';
import 'controllers/animation_level_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/reminder_controller.dart';
import 'controllers/update_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const String appVersion = 'v0.0.5';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _previewAnimController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _previewAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.18,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_previewAnimController);
  }

  @override
  void dispose() {
    _previewAnimController.dispose();
    super.dispose();
  }

  void _triggerMotionPreview(AnimationLevel level) {
    if (level.isReduced) {
      // In reduced motion, trigger no spring or scale animation
      return;
    }
    _previewAnimController.forward(from: 0.0);
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

  void _showLanguageSelectorDialog(
    BuildContext context,
    Locale? currentLocale,
    AppLocalizations? l10n,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              leading: Icon(
                currentLocale?.languageCode == 'en'
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: currentLocale?.languageCode == 'en'
                    ? primaryColor
                    : null,
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
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              leading: Icon(
                currentLocale?.languageCode == 'it'
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: currentLocale?.languageCode == 'it'
                    ? primaryColor
                    : null,
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
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: Text(l10n?.spanish ?? 'Español'),
              subtitle: Text(l10n?.comingSoon ?? 'Coming soon'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showPlaceholderNotice(context, 'Spanish translation');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectorDialog(BuildContext context, AppLocalizations? l10n) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.themeMode ?? 'Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.check_circle_rounded, color: primaryColor),
              title: Text(l10n?.themeSystem ?? 'System Default'),
              subtitle: Text(
                l10n?.themeModeSubtitle ?? 'Follow device theme settings',
              ),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showPlaceholderNotice(context, 'Theme mode');
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: Text(l10n?.themeDark ?? 'Dark Theme'),
              subtitle: const Text('Always use dark palette'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showPlaceholderNotice(context, 'Theme mode');
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: Text(l10n?.themeLight ?? 'Light Theme'),
              subtitle: const Text('Always use light palette'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showPlaceholderNotice(context, 'Theme mode');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  void _showReminderDialog(BuildContext context, AppLocalizations? l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final reminder = ref.watch(reminderControllerProvider);
            final colorScheme = Theme.of(context).colorScheme;

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
                      title: Text(
                        l10n?.enableReminders ?? 'Daily Study Reminders',
                      ),
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
                                  'Time to review with Repetita!',
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
                                      'Time to review with Repetita!',
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
                      label: Text(
                        l10n?.testNotification ?? 'Send Test Notification',
                      ),
                      onPressed: () async {
                        await ref
                            .read(reminderControllerProvider.notifier)
                            .sendTestNotification(
                              title:
                                  l10n?.notificationTitle ??
                                  'Time to review with Repetita!',
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
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n?.close ?? 'Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateCheckDialog(BuildContext context, AppLocalizations? l10n) {
    // Initiate update check
    ref
        .read(updateCheckControllerProvider.notifier)
        .checkForUpdates(currentVersion: SettingsScreen.appVersion);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, ref, _) {
            final updateState = ref.watch(updateCheckControllerProvider);
            final colorScheme = Theme.of(context).colorScheme;

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
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n?.close ?? 'Close'),
                  ),
                ],
              ),
              error: (err, stack) => AlertDialog(
                icon: Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: colorScheme.error,
                ),
                title: Text(
                  l10n?.updateCheckFailed ?? 'Could not check for updates',
                ),
                content: Text(
                  l10n?.updateCheckFailedDesc ??
                      'Please check your internet connection and try again.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
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
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(l10n?.close ?? 'Close'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
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

                // Up to date
                return AlertDialog(
                  icon: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  title: Text(l10n?.upToDate ?? 'Up to Date'),
                  content: Text(
                    l10n?.upToDateDesc(info.currentVersion) ??
                        'Repetita is currently running the latest version: ${info.currentVersion}.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(l10n?.ok ?? 'OK'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String _getLanguageDisplayText(
    Locale? currentLocale,
    AppLocalizations? l10n,
  ) {
    if (currentLocale == null) {
      return l10n?.themeSystem ?? 'System Default';
    }
    if (currentLocale.languageCode == 'it') {
      return l10n?.italian ?? 'Italiano';
    }
    return l10n?.english ?? 'English';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final currentLocale = ref.watch(localeControllerProvider);
    final animLevel = ref.watch(animationLevelControllerProvider);
    final reminderSettings = ref.watch(reminderControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.settingsTitle ?? 'Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // App Branding Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.psychology_alt_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.appTitle ?? 'Repetita',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n?.appSubtitle(SettingsScreen.appVersion) ??
                            'Offline Spaced Repetition Engine • ${SettingsScreen.appVersion}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    SettingsScreen.appVersion,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 1: Appearance & Motion
          _buildSectionHeader(context, l10n?.sectionAppearance ?? 'APPEARANCE'),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_theme_tile'),
                icon: Icons.palette_outlined,
                iconColor: colorScheme.primary,
                title: l10n?.themeMode ?? 'Theme Mode',
                subtitle:
                    l10n?.themeModeSubtitle ?? 'System default, Light, or Dark',
                trailingText: 'System',
                onTap: () => _showThemeSelectorDialog(context, l10n),
              ),
              const Divider(indent: 56, height: 1),

              // Animation Intensity Slider (Material Design 3 Expressive)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.animation_rounded,
                            color: colorScheme.tertiary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.animationIntensity ??
                                    'Animation Intensity',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                l10n?.animationIntensitySubtitle ??
                                    'Motion level and micro-interactions',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Expressive level pill badge
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  switch (animLevel) {
                                    AnimationLevel.reduced =>
                                      Icons.motion_photos_off_outlined,
                                    AnimationLevel.standard =>
                                      Icons.motion_photos_auto_outlined,
                                    AnimationLevel.expressive =>
                                      Icons.auto_awesome_rounded,
                                  },
                                  size: 14,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  switch (animLevel) {
                                    AnimationLevel.reduced =>
                                      l10n?.animationReduced ?? 'Reduced',
                                    AnimationLevel.standard =>
                                      l10n?.animationStandard ?? 'Standard',
                                    AnimationLevel.expressive =>
                                      l10n?.animationExpressive ?? 'Expressive',
                                  },
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Material 3 Slider with discrete step division
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        activeTrackColor: colorScheme.primary,
                        inactiveTrackColor: colorScheme.surfaceContainerHighest,
                        thumbColor: colorScheme.primary,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                          elevation: 2,
                        ),
                        overlayColor: colorScheme.primary.withValues(
                          alpha: 0.16,
                        ),
                        tickMarkShape: const RoundSliderTickMarkShape(
                          tickMarkRadius: 3,
                        ),
                        activeTickMarkColor: colorScheme.onPrimary,
                        inactiveTickMarkColor: colorScheme.outline,
                      ),
                      child: Slider(
                        key: const Key('setting_animation_slider'),
                        value: animLevel.value.toDouble(),
                        min: 0.0,
                        max: 2.0,
                        divisions: 2,
                        label: switch (animLevel) {
                          AnimationLevel.reduced =>
                            l10n?.animationReduced ?? 'Reduced',
                          AnimationLevel.standard =>
                            l10n?.animationStandard ?? 'Standard',
                          AnimationLevel.expressive =>
                            l10n?.animationExpressive ?? 'Expressive',
                        },
                        onChanged: (val) {
                          final newLevel = AnimationLevel.fromValue(
                            val.round(),
                          );
                          ref
                              .read(animationLevelControllerProvider.notifier)
                              .setLevel(newLevel);
                          _triggerMotionPreview(newLevel);
                        },
                      ),
                    ),

                    // Step labels below slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n?.animationReduced ?? 'Reduced',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: animLevel.isReduced
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: animLevel.isReduced
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          Text(
                            l10n?.animationStandard ?? 'Standard',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: animLevel.isStandard
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: animLevel.isStandard
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          Text(
                            l10n?.animationExpressive ?? 'Expressive',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: animLevel.isExpressive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: animLevel.isExpressive
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Contextual descriptive card with live test preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.45,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              switch (animLevel) {
                                AnimationLevel.reduced =>
                                  l10n?.animationReducedDesc ?? 'Instant transitions, battery-friendly, accessibility-ready',
                                AnimationLevel.standard =>
                                  l10n?.animationStandardDesc ??
                                      'Balanced Material 3 fluid transitions',
                                AnimationLevel.expressive =>
                                  l10n?.animationExpressiveDesc ?? 'Playful spring physics, bouncy feedback, and lively motion',
                              },
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            key: const Key('test_motion_button'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.touch_app_rounded, size: 16),
                            label: Text(
                              l10n?.testMotion ?? 'Test Motion',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () => _triggerMotionPreview(animLevel),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 2: Language & Region
          _buildSectionHeader(
            context,
            l10n?.sectionLanguage ?? 'LANGUAGE & LOCALIZATION',
          ),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_language_tile'),
                icon: Icons.translate_rounded,
                iconColor: colorScheme.secondary,
                title: l10n?.language ?? 'Language',
                subtitle:
                    l10n?.languageSubtitle ?? 'Select app interface language',
                trailingText: _getLanguageDisplayText(currentLocale, l10n),
                onTap: () =>
                    _showLanguageSelectorDialog(context, currentLocale, l10n),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 3: Algorithm & Study (FSRS)
          _buildSectionHeader(
            context,
            l10n?.sectionStudyAlgorithm ?? 'STUDY & ALGORITHM',
          ),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_fsrs_tile'),
                icon: Icons.tune_rounded,
                iconColor: colorScheme.tertiary,
                title: l10n?.fsrsParameters ?? 'FSRS Scheduling Parameters',
                subtitle:
                    l10n?.fsrsParametersSubtitle ??
                    'Desired retention, max intervals, request weights',
                trailingText: l10n?.retentionTarget ?? '90% retention',
                onTap: () =>
                    _showPlaceholderNotice(context, 'FSRS parameter tuning'),
              ),
              const Divider(indent: 56, height: 1),
              _SettingsTile(
                key: const Key('setting_notifications_tile'),
                icon: reminderSettings.enabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                iconColor: colorScheme.primary,
                title: l10n?.studyReminders ?? 'Study Reminders',
                subtitle: reminderSettings.enabled
                    ? 'Daily review notification at ${reminderSettings.formattedTime}'
                    : (l10n?.studyRemindersSubtitle ??
                          'Daily review notifications'),
                trailingText: reminderSettings.enabled
                    ? reminderSettings.formattedTime
                    : (l10n?.remindersOff ?? 'Off'),
                onTap: () => _showReminderDialog(context, l10n),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 4: Updates & Maintenance
          _buildSectionHeader(
            context,
            l10n?.sectionUpdates ?? 'UPDATES & RELEASES',
          ),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_github_update_tile'),
                icon: Icons.system_update_alt_rounded,
                iconColor: colorScheme.primary,
                title: l10n?.checkForUpdates ?? 'Check for Updates',
                subtitle:
                    l10n?.checkForUpdatesSubtitle ??
                    'Verify installed version against GitHub releases',
                trailingText: SettingsScreen.appVersion,
                onTap: () => _showUpdateCheckDialog(context, l10n),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 5: About & Privacy
          _buildSectionHeader(context, l10n?.sectionAbout ?? 'ABOUT & PRIVACY'),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_privacy_tile'),
                icon: Icons.lock_outline_rounded,
                iconColor: colorScheme.secondary,
                title: l10n?.offlinePrivacy ?? 'Local & Offline-First',
                subtitle:
                    l10n?.offlinePrivacySubtitle ??
                    'Zero cloud telemetry, zero remote tracking',
                trailingText: l10n?.active ?? 'Active',
                onTap: () => _showPlaceholderNotice(context, 'Privacy details'),
              ),
              const Divider(indent: 56, height: 1),
              _SettingsTile(
                key: const Key('setting_license_tile'),
                icon: Icons.description_outlined,
                iconColor: colorScheme.outline,
                title: l10n?.licenseAndCredits ?? 'License & Credits',
                subtitle: l10n?.licenseSubtitle ?? 'MIT License • Open Source',
                onTap: () => _showPlaceholderNotice(context, 'License info'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailingText,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                trailingText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: colorScheme.outline,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
