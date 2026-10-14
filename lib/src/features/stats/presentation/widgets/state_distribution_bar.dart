import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/card_state_colors.dart';
import '../../domain/stats_models.dart';

class StateDistributionBar extends StatelessWidget {
  const StateDistributionBar({super.key, required this.counts});

  final CardStateCounts counts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final total = counts.total;

    final segments = [
      _Segment(
        name: cardStateName(0, l10n),
        count: counts.newCount,
        color: colorScheme.cardStateColor(0),
      ),
      _Segment(
        name: cardStateName(1, l10n),
        count: counts.learningCount,
        color: colorScheme.cardStateColor(1),
      ),
      _Segment(
        name: cardStateName(2, l10n),
        count: counts.reviewCount,
        color: colorScheme.cardStateColor(2),
      ),
      _Segment(
        name: cardStateName(3, l10n),
        count: counts.relearningCount,
        color: colorScheme.cardStateColor(3),
      ),
    ];

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.cardStateBreakdown ?? 'Card State Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n?.totalCount(total) ?? '$total total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: total == 0
                    ? Container(color: colorScheme.surfaceContainerHighest)
                    : Row(
                        children: segments.map((seg) {
                          if (seg.count == 0) return const SizedBox.shrink();
                          return Expanded(
                            flex: seg.count,
                            child: Container(color: seg.color),
                          );
                        }).toList(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: segments.map((seg) {
                final pct = total > 0 ? (seg.count / total * 100).round() : 0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: seg.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${seg.name}: ${seg.count} ($pct%)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment {
  const _Segment({
    required this.name,
    required this.count,
    required this.color,
  });

  final String name;
  final int count;
  final Color color;
}
