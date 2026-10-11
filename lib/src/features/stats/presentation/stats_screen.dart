import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/stats_controller.dart';
import 'widgets/forecast_list_tile.dart';
import 'widgets/metric_summary_card.dart';
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
    final statsAsync = ref.watch(statsControllerProvider(deckId: deckId));

    final title = deckName != null ? '$deckName Stats' : 'Statistics';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: !isEmbedded,
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error loading statistics: $error',
            style: TextStyle(color: colorScheme.error),
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
                      title: 'Retention',
                      subtitle: 'Recall accuracy',
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricSummaryCard(
                      icon: Icons.history,
                      value: '${stats.totalReviews}',
                      title: 'Reviews',
                      subtitle: 'Total completed',
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
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
    );
  }
}
