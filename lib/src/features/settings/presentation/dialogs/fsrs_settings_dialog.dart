import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../controllers/fsrs_parameters_controller.dart';

class FsrsSettingsDialog extends ConsumerWidget {
  const FsrsSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const FsrsSettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final fsrsParams = ref.watch(fsrsParametersControllerProvider);
    final controller = ref.read(fsrsParametersControllerProvider.notifier);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.tune_rounded, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n?.fsrsParameters ?? 'FSRS Scheduling Parameters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Desired Retention
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.desiredRetention ?? 'Desired Retention',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${(fsrsParams.requestRetention * 100).round()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.desiredRetentionDesc ?? 'Target recall probability at review time. Higher retention requires more frequent reviews.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Slider(
              key: const Key('fsrs_retention_slider'),
              value: fsrsParams.requestRetention,
              min: 0.70,
              max: 0.98,
              divisions: 28,
              label: '${(fsrsParams.requestRetention * 100).round()}%',
              onChanged: (val) {
                controller.setRequestRetention(
                  double.parse(val.toStringAsFixed(2)),
                );
              },
            ),
            const SizedBox(height: 16),

            // Maximum Interval
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.maxInterval ?? 'Maximum Interval',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    fsrsParams.maximumInterval >= 36500
                        ? '100 years'
                        : '${fsrsParams.maximumInterval} days',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.maxIntervalDesc ??
                  'Maximum spacing interval between reviews in days.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [30, 90, 180, 365, 3650, 36500].map((days) {
                final isSelected = fsrsParams.maximumInterval == days;
                return ChoiceChip(
                  key: Key('fsrs_interval_$days'),
                  label: Text(
                    days == 36500 ? 'Max (36500d)' : '${days}d',
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: isSelected,
                  onSelected: (_) => controller.setMaximumInterval(days),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Weights summary & Reset
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                l10n?.fsrsWeights ?? 'FSRS Model Weights',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '17 model parameters (v4.5 / v5)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    fsrsParams.w
                        .asMap()
                        .entries
                        .map((e) => 'w${e.key}: ${e.value}')
                        .join(', '),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('fsrs_reset_button'),
              icon: const Icon(Icons.restore_rounded, size: 16),
              label: Text(l10n?.resetFsrsDefaults ?? 'Reset to Defaults'),
              onPressed: () => controller.resetToDefaults(),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          key: const Key('fsrs_save_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.ok ?? 'OK'),
        ),
      ],
    );
  }
}
