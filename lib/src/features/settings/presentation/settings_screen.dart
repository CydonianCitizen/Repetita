import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../backup_transfer/presentation/backup_screen.dart';
import '../data/haptic_service.dart';
import '../domain/animation_level.dart';
import '../domain/haptic_intensity.dart';
import 'controllers/animation_level_controller.dart';
import 'controllers/fsrs_parameters_controller.dart';
import 'controllers/haptic_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/reminder_controller.dart';
import 'controllers/theme_mode_controller.dart';
import 'dialogs/fsrs_settings_dialog.dart';
import 'dialogs/language_selector_dialog.dart';
import 'dialogs/license_dialog.dart';
import 'dialogs/reminder_dialog.dart';
import 'dialogs/theme_selector_dialog.dart';
import 'dialogs/update_check_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.isEmbedded = false});

  final bool isEmbedded;

  static const String appVersion = 'v0.3.0';

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

  String _themeModeLabel(ThemeMode mode, AppLocalizations? l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n?.themeSystem ?? 'System Default';
      case ThemeMode.dark:
        return l10n?.themeDark ?? 'Dark Theme';
      case ThemeMode.light:
        return l10n?.themeLight ?? 'Light Theme';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final currentLocale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final animLevel = ref.watch(animationLevelControllerProvider);
    final hapticIntensity = ref.watch(hapticFeedbackControllerProvider);
    final reminderSettings = ref.watch(reminderControllerProvider);

    final fsrsParams = ref.watch(fsrsParametersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsTitle ?? 'Settings'),
        automaticallyImplyLeading: !widget.isEmbedded,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // App Branding Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.appTitle ?? 'repetita',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
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
                    horizontal: 10,
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
                trailingText: _themeModeLabel(themeMode, l10n),
                onTap: () => ThemeSelectorDialog.show(context),
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
              const Divider(indent: 56, height: 1),

              // Haptic Feedback Intensity Slider (Material Design 3 Expressive)
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
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.vibration_rounded,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.hapticFeedback ?? 'Haptic Feedback',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                l10n?.hapticFeedbackSubtitle ?? 'Vibrations on answer ratings and interactions',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Expressive level pill badge
                        Container(
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
                                switch (hapticIntensity) {
                                  HapticIntensity.off =>
                                    Icons.notifications_off_outlined,
                                  HapticIntensity.light =>
                                    Icons.touch_app_outlined,
                                  HapticIntensity.medium =>
                                    Icons.vibration_rounded,
                                  HapticIntensity.strong =>
                                    Icons.sensors_rounded,
                                },
                                size: 14,
                                color: colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                switch (hapticIntensity) {
                                  HapticIntensity.off =>
                                    l10n?.hapticOff ?? 'Off',
                                  HapticIntensity.light =>
                                    l10n?.hapticLight ?? 'Light',
                                  HapticIntensity.medium =>
                                    l10n?.hapticMedium ?? 'Medium',
                                  HapticIntensity.strong =>
                                    l10n?.hapticStrong ?? 'Strong',
                                },
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
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
                        key: const Key('setting_haptic_slider'),
                        value: hapticIntensity.level.toDouble(),
                        min: 0.0,
                        max: 3.0,
                        divisions: 3,
                        label: switch (hapticIntensity) {
                          HapticIntensity.off => l10n?.hapticOff ?? 'Off',
                          HapticIntensity.light => l10n?.hapticLight ?? 'Light',
                          HapticIntensity.medium =>
                            l10n?.hapticMedium ?? 'Medium',
                          HapticIntensity.strong =>
                            l10n?.hapticStrong ?? 'Strong',
                        },
                        onChanged: (val) {
                          final newIntensity = HapticIntensity.fromLevel(
                            val.round(),
                          );
                          ref
                              .read(hapticFeedbackControllerProvider.notifier)
                              .setIntensity(newIntensity);
                          ref
                              .read(hapticServiceProvider)
                              .triggerTest(newIntensity);
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
                            l10n?.hapticOff ?? 'Off',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: hapticIntensity == HapticIntensity.off
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: hapticIntensity == HapticIntensity.off
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          Text(
                            l10n?.hapticLight ?? 'Light',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight:
                                  hapticIntensity == HapticIntensity.light
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: hapticIntensity == HapticIntensity.light
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          Text(
                            l10n?.hapticMedium ?? 'Medium',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight:
                                  hapticIntensity == HapticIntensity.medium
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: hapticIntensity == HapticIntensity.medium
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          Text(
                            l10n?.hapticStrong ?? 'Strong',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight:
                                  hapticIntensity == HapticIntensity.strong
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: hapticIntensity == HapticIntensity.strong
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
                              switch (hapticIntensity) {
                                HapticIntensity.off =>
                                  l10n?.hapticOffDesc ?? 'Vibrations disabled',
                                HapticIntensity.light =>
                                  l10n?.hapticLightDesc ??
                                      'Subtle tactile clicks',
                                HapticIntensity.medium =>
                                  l10n?.hapticMediumDesc ??
                                      'Balanced physical response',
                                HapticIntensity.strong =>
                                  l10n?.hapticStrongDesc ??
                                      'Prominent tactile buzz and pulses',
                              },
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            key: const Key('test_haptic_button'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.vibration_rounded, size: 16),
                            label: Text(
                              l10n?.testHaptic ?? 'Test Haptics',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () => ref
                                .read(hapticServiceProvider)
                                .triggerTest(hapticIntensity),
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
                onTap: () => LanguageSelectorDialog.show(context),
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
                trailingText: '${(fsrsParams.requestRetention * 100).round()}%',
                onTap: () => FsrsSettingsDialog.show(context),
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
                onTap: () => ReminderDialog.show(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 4: Data & Backup
          _buildSectionHeader(
            context,
            l10n?.sectionDataBackup ?? 'DATA & BACKUP',
          ),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_backup_tile'),
                icon: Icons.backup_outlined,
                iconColor: colorScheme.primary,
                title: l10n?.backup ?? 'Backup & Restore',
                subtitle:
                    l10n?.backupSubtitle ??
                    'Export and import decks via JSON or CSV',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BackupScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 5: Updates & Releases
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
                onTap: () => UpdateCheckDialog.show(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 6: About & License
          _buildSectionHeader(context, l10n?.sectionAbout ?? 'ABOUT & PRIVACY'),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_license_tile'),
                icon: Icons.description_outlined,
                iconColor: colorScheme.outline,
                title: l10n?.licenseAndCredits ?? 'License & Credits',
                subtitle: l10n?.licenseSubtitle ?? 'MIT License • Open Source',
                onTap: () => LicenseDialog.show(context),
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
