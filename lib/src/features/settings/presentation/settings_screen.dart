import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String appVersion = 'v0.0.5';

  void _showPlaceholderNotice(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming in an upcoming release!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguageSelectorDialog(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.check_circle_rounded,
                color: primaryColor,
              ),
              title: const Text('English (Default)'),
              subtitle: const Text('Current active language'),
              onTap: () {
                Navigator.of(context).pop();
                _showPlaceholderNotice(context, 'Language switching');
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: const Text('Italiano'),
              subtitle: const Text('Prossimamente / In arrivo'),
              onTap: () {
                Navigator.of(context).pop();
                _showPlaceholderNotice(context, 'Traduzione in Italiano');
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: const Text('Español'),
              subtitle: const Text('Próximamente'),
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectorDialog(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.check_circle_rounded,
                color: primaryColor,
              ),
              title: const Text('System Default'),
              subtitle: const Text('Follow device theme settings'),
              onTap: () {
                Navigator.of(context).pop();
                _showPlaceholderNotice(context, 'Theme mode');
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: const Text('Dark Theme'),
              subtitle: const Text('Always use dark palette'),
              onTap: () {
                Navigator.of(context).pop();
                _showPlaceholderNotice(context, 'Theme mode');
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: const Text('Light Theme'),
              subtitle: const Text('Always use light palette'),
              onTap: () {
                Navigator.of(context).pop();
                _showPlaceholderNotice(context, 'Theme mode');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUpdateCheckDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline_rounded, size: 48),
        title: const Text('Up to Date'),
        content: const Text(
          'Repetita is currently running the latest version: $appVersion.\n\nAutomatic GitHub release checks will be enabled soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // App Banner / Branding
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
                        'Repetita',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Offline Spaced Repetition Engine • $appVersion',
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
                    appVersion,
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

          // Section 1: Appearance
          _buildSectionHeader(context, 'APPEARANCE'),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_theme_tile'),
                icon: Icons.palette_outlined,
                iconColor: colorScheme.primary,
                title: 'Theme Mode',
                subtitle: 'System default, Light, or Dark',
                trailingText: 'System',
                onTap: () => _showThemeSelectorDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 2: Language & Region
          _buildSectionHeader(context, 'LANGUAGE & LOCALIZATION'),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_language_tile'),
                icon: Icons.translate_rounded,
                iconColor: colorScheme.secondary,
                title: 'Language',
                subtitle: 'English, Italiano, and more',
                trailingText: 'English',
                onTap: () => _showLanguageSelectorDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 3: Algorithm & Study (FSRS)
          _buildSectionHeader(context, 'STUDY & ALGORITHM'),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_fsrs_tile'),
                icon: Icons.tune_rounded,
                iconColor: colorScheme.tertiary,
                title: 'FSRS Scheduling Parameters',
                subtitle: 'Desired retention, max intervals, request weights',
                trailingText: '90% retention',
                onTap: () =>
                    _showPlaceholderNotice(context, 'FSRS parameter tuning'),
              ),
              const Divider(indent: 56, height: 1),
              _SettingsTile(
                key: const Key('setting_notifications_tile'),
                icon: Icons.notifications_none_rounded,
                iconColor: colorScheme.primary,
                title: 'Study Reminders',
                subtitle: 'Daily review notifications',
                trailingText: 'Off',
                onTap: () => _showPlaceholderNotice(context, 'Study reminders'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 4: Updates & Maintenance
          _buildSectionHeader(context, 'UPDATES & RELEASES'),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_github_update_tile'),
                icon: Icons.system_update_alt_rounded,
                iconColor: colorScheme.primary,
                title: 'Check for Updates',
                subtitle: 'Verify installed version against GitHub releases',
                trailingText: appVersion,
                onTap: () => _showUpdateCheckDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section 5: About & Privacy
          _buildSectionHeader(context, 'ABOUT & PRIVACY'),
          _buildSettingsCard(
            context,
            children: [
              _SettingsTile(
                key: const Key('setting_privacy_tile'),
                icon: Icons.lock_outline_rounded,
                iconColor: colorScheme.secondary,
                title: 'Local & Offline-First',
                subtitle: 'Zero cloud telemetry, zero remote tracking',
                trailingText: 'Active',
                onTap: () => _showPlaceholderNotice(context, 'Privacy details'),
              ),
              const Divider(indent: 56, height: 1),
              _SettingsTile(
                key: const Key('setting_license_tile'),
                icon: Icons.description_outlined,
                iconColor: colorScheme.outline,
                title: 'License & Credits',
                subtitle: 'MIT License • Open Source',
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
