import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/algorithms/fsrs/models/rating.dart';
import '../../../../core/l10n/generated/app_localizations.dart';

class RatingBar extends StatelessWidget {
  const RatingBar({
    super.key,
    required this.intervals,
    required this.onRatingSelected,
  });

  final Map<Rating, String> intervals;
  final ValueChanged<Rating> onRatingSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final configs = [
      _RatingConfig(
        rating: Rating.again,
        label: l10n?.ratingAgain ?? 'Again',
        key: const Key('rating_button_again'),
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
      ),
      _RatingConfig(
        rating: Rating.hard,
        label: l10n?.ratingHard ?? 'Hard',
        key: const Key('rating_button_hard'),
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
      ),
      _RatingConfig(
        rating: Rating.good,
        label: l10n?.ratingGood ?? 'Good',
        key: const Key('rating_button_good'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      _RatingConfig(
        rating: Rating.easy,
        label: l10n?.ratingEasy ?? 'Easy',
        key: const Key('rating_button_easy'),
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: configs.asMap().entries.map((entry) {
          final index = entry.key;
          final cfg = entry.value;
          final rawInterval = intervals[cfg.rating] ?? '';
          final interval = rawInterval == 'Re-queue'
              ? (l10n?.cramRequeue ?? 'Re-queue')
              : (rawInterval == 'Pass'
                    ? (l10n?.cramPass ?? 'Pass')
                    : rawInterval);

          return Expanded(
            child:
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Semantics(
                        button: true,
                        label:
                            l10n?.rateButtonSemantics(cfg.label, interval) ??
                            'Rate ${cfg.label}, next review in $interval',
                        child: FilledButton.tonal(
                          key: cfg.key,
                          onPressed: () => onRatingSelected(cfg.rating),
                          style: FilledButton.styleFrom(
                            backgroundColor: cfg.backgroundColor,
                            foregroundColor: cfg.foregroundColor,
                            minimumSize: const Size(48, 56),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 1,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cfg.label,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: cfg.foregroundColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                interval,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cfg.foregroundColor.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 180.ms, delay: (index * 35).ms)
                    .scale(
                      duration: 180.ms,
                      delay: (index * 35).ms,
                      begin: const Offset(0.92, 0.92),
                      curve: Curves.easeOutBack,
                    ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 150.ms);
  }
}

class _RatingConfig {
  const _RatingConfig({
    required this.rating,
    required this.label,
    required this.key,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Rating rating;
  final String label;
  final Key key;
  final Color backgroundColor;
  final Color foregroundColor;
}
