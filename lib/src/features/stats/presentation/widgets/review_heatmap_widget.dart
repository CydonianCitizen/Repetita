import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';

class ReviewHeatmapWidget extends StatelessWidget {
  const ReviewHeatmapWidget({
    super.key,
    required this.dailyCounts,
    this.currentStreak = 0,
    this.weeks = 15,
    this.referenceDate,
  });

  final Map<DateTime, int> dailyCounts;
  final int currentStreak;
  final int weeks;
  final DateTime? referenceDate;

  Color _cellColor(int count, ColorScheme scheme) {
    if (count == 0) {
      return scheme.surfaceContainerHighest.withValues(alpha: 0.5);
    } else if (count < 5) {
      return scheme.primary.withValues(alpha: 0.35);
    } else if (count < 10) {
      return scheme.primary.withValues(alpha: 0.65);
    } else {
      return scheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final ref = referenceDate?.toUtc() ?? DateTime.now().toUtc();
    final today = DateTime.utc(ref.year, ref.month, ref.day);

    // End on Sunday of current week
    final daysUntilSunday = 7 - today.weekday;
    final endSunday = today.add(Duration(days: daysUntilSunday));
    final startMonday = endSunday.subtract(Duration(days: (weeks * 7) - 1));

    int totalVisibleReviews = 0;
    dailyCounts.forEach((date, count) {
      if (!date.isBefore(startMonday) && !date.isAfter(today)) {
        totalVisibleReviews += count;
      }
    });

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.reviewHeatmap ?? 'Review Heatmap',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: currentStreak > 0
                        ? Colors.deepOrange.withValues(alpha: 0.15)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: currentStreak > 0
                            ? Colors.deepOrange
                            : scheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n?.daysStreak(currentStreak) ??
                            '$currentStreak ${currentStreak == 1 ? "day" : "days"}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: currentStreak > 0
                              ? Colors.deepOrange
                              : scheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekday labels: Mon, Wed, Fri
                  Padding(
                    padding: const EdgeInsets.only(right: 6, top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _WeekdayLabel(text: 'M', theme: theme),
                        const SizedBox(height: 18),
                        _WeekdayLabel(text: 'W', theme: theme),
                        const SizedBox(height: 18),
                        _WeekdayLabel(text: 'F', theme: theme),
                      ],
                    ),
                  ),
                  // Weeks columns
                  Row(
                    children: List.generate(weeks, (col) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          children: List.generate(7, (row) {
                            final cellDate = startMonday.add(
                              Duration(days: col * 7 + row),
                            );
                            final isFuture = cellDate.isAfter(today);
                            final count = isFuture
                                ? 0
                                : (dailyCounts[cellDate] ?? 0);

                            if (isFuture) {
                              return Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }

                            final dateStr =
                                '${cellDate.year}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}';
                            final tooltip = count == 1
                                ? '1 review on $dateStr'
                                : '$count reviews on $dateStr';

                            return Tooltip(
                              message: tooltip,
                              waitDuration: const Duration(milliseconds: 300),
                              child: Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: _cellColor(count, scheme),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalVisibleReviews ${l10n?.reviews.toLowerCase() ?? "reviews"} in period',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Less',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _LegendBox(color: _cellColor(0, scheme)),
                    _LegendBox(color: _cellColor(1, scheme)),
                    _LegendBox(color: _cellColor(5, scheme)),
                    _LegendBox(color: _cellColor(10, scheme)),
                    const SizedBox(width: 4),
                    Text(
                      'More',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel({required this.text, required this.theme});

  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.outline,
          fontSize: 9,
          height: 1.2,
        ),
      ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  const _LegendBox({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
