import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../domain/stats_models.dart';

class ForecastListTile extends StatelessWidget {
  const ForecastListTile({
    super.key,
    required this.forecast,
    required this.index,
    required this.maxCount,
    this.isDense = false,
  });

  final ForecastDay forecast;
  final int index;
  final int maxCount;
  final bool isDense;

  static final Map<String, DateFormat> _formatters = {};

  static DateFormat _getFormatter(String locale) =>
      _formatters.putIfAbsent(locale, () => DateFormat('E, MMM d', locale));

  String _formatDate(BuildContext context, DateTime date, int index) {
    final l10n = AppLocalizations.of(context);
    if (index == 0) return l10n?.today ?? 'Today';
    if (index == 1) return l10n?.tomorrow ?? 'Tomorrow';
    final locale = Localizations.localeOf(context).toString();
    return _getFormatter(locale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ratio = maxCount > 0
        ? (forecast.count / maxCount).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDense ? 3 : 6),
      child: Row(
        children: [
          SizedBox(
            width: isDense ? 95 : 110,
            child: Text(
              _formatDate(context, forecast.date, index),
              style:
                  (isDense
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(
                        fontWeight: index == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: index == 0
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: isDense ? 7 : 10,
                semanticsLabel: 'Due forecast count',
                semanticsValue: '${(ratio * 100).round()}%',
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  index == 0 ? colorScheme.primary : colorScheme.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 32,
            child: Text(
              '${forecast.count}',
              textAlign: TextAlign.end,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
