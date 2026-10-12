import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import 'controllers/stats_controller.dart';
import 'widgets/forecast_list_tile.dart';
import 'widgets/metric_summary_card.dart';
import 'widgets/review_heatmap_widget.dart';
import 'widgets/state_distribution_bar.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({
    super.key,
    this.deckId,
    this.deckName,
    this.isEmbedded = false,
  });

  final int? deckId;
  final String? deckName;
  final bool isEmbedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(statsControllerProvider(deckId: deckId));

    final title = deckName != null
        ? (l10n?.deckStatsTitle(deckName!) ?? '$deckName Stats')
        : (l10n?.stats ?? 'Statistics');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: !isEmbedded,
      ),
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.errorLoadingStats ?? 'Error loading statistics',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        ref.invalidate(statsControllerProvider(deckId: deckId)),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n?.retry ?? 'Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (stats) {
            final retentionPct = (stats.retentionRate * 100).round();
            final maxForecast = stats.forecast.fold<int>(
              0,
              (maxVal, item) => max(maxVal, item.count),
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricSummaryCard(
                        icon: Icons.percent,
                        value: '$retentionPct%',
                        title: l10n?.retention ?? 'Retention',
                        subtitle: l10n?.recallAccuracy ?? 'Recall accuracy',
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricSummaryCard(
                        icon: Icons.history,
                        value: '${stats.totalReviews}',
                        title: l10n?.reviews ?? 'Reviews',
                        subtitle: l10n?.reviewsCompleted ?? 'Total completed',
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ReviewHeatmapWidget(
                  dailyCounts: stats.dailyReviewCounts,
                  currentStreak: stats.currentStreak,
                ),
                const SizedBox(height: 16),
                StateDistributionBar(counts: stats.stateCounts),
                const SizedBox(height: 16),
                Card(
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
                              l10n?.reviewForecastTitle ??
                                  '7-Day Review Forecast',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: colorScheme.outline,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (stats.forecast.isEmpty)
                          Text(
                            l10n?.noUpcomingReviews ??
                                'No upcoming reviews scheduled.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                        else
                          ...stats.forecast.asMap().entries.map((entry) {
                            return ForecastListTile(
                              forecast: entry.value,
                              index: entry.key,
                              maxCount: maxForecast,
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
