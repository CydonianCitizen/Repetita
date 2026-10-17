import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../cards/domain/card_entity.dart';
import '../../domain/exam_study_planner.dart';

class ExamPlanCard extends StatelessWidget {
  const ExamPlanCard({
    super.key,
    required this.deck,
    required this.cards,
    required this.now,
    required this.onSetExamDate,
    required this.onClearExamDate,
  });

  final Deck deck;
  final List<CardEntity> cards;
  final DateTime now;
  final VoidCallback onSetExamDate;
  final VoidCallback onClearExamDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (deck.examDate == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: OutlinedButton.icon(
          key: const Key('set_exam_date_button'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.event_outlined),
          label: Text(l10n?.setExamDate ?? 'Set Exam Date'),
          onPressed: onSetExamDate,
        ),
      );
    }

    final newCardsCount = cards.where((c) => c.state == 0).length;
    final reviewCardsCount = cards.where((c) => c.state != 0).length;

    const planner = ExamStudyPlanner();
    final plan = planner.calculatePlan(
      now: now,
      examDate: deck.examDate!,
      newCardsCount: newCardsCount,
      reviewCardsCount: reviewCardsCount,
      targetRetention: deck.targetRetention,
    );

    return Container(
      key: const Key('exam_plan_card'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: plan.isUnsustainable
            ? colorScheme.errorContainer.withValues(alpha: 0.3)
            : colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isUnsustainable
              ? colorScheme.error.withValues(alpha: 0.5)
              : colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                color: plan.isUnsustainable
                    ? colorScheme.error
                    : colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.examPlan ?? 'Exam Study Plan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                backgroundColor: colorScheme.surface,
                label: Text(
                  l10n?.daysRemaining(plan.daysRemaining) ??
                      '${plan.daysRemaining} days remaining',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    onSetExamDate();
                  } else if (value == 'clear') {
                    onClearExamDate();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_calendar, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n?.edit ?? 'Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.event_busy, size: 18, color: colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.clearExamDate ?? 'Clear Exam Date',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _PlanMetricChip(
                icon: Icons.fiber_new_rounded,
                label: l10n?.dailyNewTarget(plan.dailyNewCardsQuota) ??
                    'Target: ${plan.dailyNewCardsQuota} new/day',
              ),
              _PlanMetricChip(
                icon: Icons.repeat_rounded,
                label: l10n?.estimatedReviews(plan.estimatedDailyReviews) ??
                    '~${plan.estimatedDailyReviews} reviews/day',
              ),
              _PlanMetricChip(
                icon: Icons.track_changes_rounded,
                label: l10n?.retentionTarget(
                      (plan.suggestedRetention * 100).toInt(),
                    ) ??
                    'Retention target: ${(plan.suggestedRetention * 100).toInt()}%',
              ),
            ],
          ),
          if (plan.isUnsustainable) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n?.unsustainableWorkload ??
                        'Heavy workload! You may want to start earlier or lower retention target.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanMetricChip extends StatelessWidget {
  const _PlanMetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
