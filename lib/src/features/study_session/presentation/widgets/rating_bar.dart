import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/algorithms/fsrs/models/fsrs_models.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../settings/presentation/controllers/animation_level_controller.dart';

class RatingBar extends ConsumerWidget {
  const RatingBar({
    super.key,
    required this.intervals,
    required this.onRatingSelected,
  });

  final Map<Rating, String> intervals;
  final ValueChanged<Rating> onRatingSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final animLevel = ref.watch(animationLevelControllerProvider);
    final isReduced = animLevel.isReduced;
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

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

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final buttons = configs.asMap().entries.map((entry) {
          final index = entry.key;
          final cfg = entry.value;
          final rawInterval = intervals[cfg.rating] ?? '';
          final interval = rawInterval == 'Re-queue'
              ? (l10n?.cramRequeue ?? 'Re-queue')
              : (rawInterval == 'Pass'
                    ? (l10n?.cramPass ?? 'Pass')
                    : rawInterval);

          Widget btn = Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
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
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: compact ? 4 : 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cfg.label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: cfg.foregroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: compact ? 13 : null,
                          ),
                        ),
                        if (isDesktop && !compact) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: cfg.foregroundColor.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cfg.foregroundColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      interval,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cfg.foregroundColor.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: compact ? 10 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          if (!isReduced) {
            btn = btn
                .animate()
                .fadeIn(duration: 180.ms, delay: (index * 35).ms)
                .scale(
                  duration: 180.ms,
                  delay: (index * 35).ms,
                  begin: const Offset(0.92, 0.92),
                  curve: Curves.easeOutBack,
                );
          }

          return Expanded(child: btn);
        }).toList();

        return Row(children: buttons);
      },
    );

    if (!isReduced) {
      content = content.animate().fadeIn(duration: 150.ms);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: content,
    );
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
