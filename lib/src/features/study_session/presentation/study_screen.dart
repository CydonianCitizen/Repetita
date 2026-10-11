import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import 'controllers/study_session_controller.dart';
import '../../settings/data/haptic_service.dart';
import '../../settings/presentation/controllers/haptic_controller.dart';
import 'widgets/flip_card_view.dart';
import 'widgets/rating_bar.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key, required this.deckId});

  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(studySessionControllerProvider(deckId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.studySessionTitle ?? 'Study Session'),
        actions: [
          if (stateAsync.value?.canUndo == true)
            IconButton(
              key: const Key('undo_review_button'),
              icon: const Icon(Icons.undo_rounded),
              tooltip: l10n?.undoReview ?? 'Undo Review',
              onPressed: () async {
                await ref
                    .read(studySessionControllerProvider(deckId).notifier)
                    .undoReview();
              },
            ),
          if (stateAsync.value?.currentCard != null)
            PopupMenuButton<String>(
              key: const Key('study_card_actions_menu'),
              icon: const Icon(Icons.more_vert),
              tooltip: l10n?.cardOptions ?? 'Card options',
              onSelected: (value) async {
                final controller = ref.read(
                  studySessionControllerProvider(deckId).notifier,
                );
                if (value == 'suspend') {
                  await controller.suspendCurrentCard();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n?.cardSuspended ?? 'Card suspended'),
                      ),
                    );
                  }
                } else if (value == 'bury') {
                  await controller.buryCurrentCard();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.cardBuried ?? 'Card buried until tomorrow',
                        ),
                      ),
                    );
                  }
                }
              },
              itemBuilder: (context) {
                final itemL10n = AppLocalizations.of(context);
                return [
                  PopupMenuItem(
                    value: 'bury',
                    child: Row(
                      children: [
                        const Icon(Icons.alarm_off_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(itemL10n?.buryCard ?? 'Bury Card'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'suspend',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pause_circle_outline_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(itemL10n?.suspendCard ?? 'Suspend Card'),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            '${l10n?.errorLoadingStudySession ?? "Error loading study session"}: $error',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
        data: (sessionState) {
          if (sessionState.isCompleted || sessionState.currentCard == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            size: 56,
                            color: colorScheme.primary,
                          ),
                        )
                        .animate()
                        .scale(
                          duration: 450.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(0.35, 0.35),
                        )
                        .fadeIn(duration: 250.ms)
                        .then()
                        .shimmer(
                          duration: 1200.ms,
                          color: colorScheme.primary.withValues(alpha: 0.35),
                        ),
                    const SizedBox(height: 28),
                    Text(
                          'All cards reviewed for today!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 300.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 12),
                    Text(
                      'Great job! Check back later for upcoming reviews.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
                    const SizedBox(height: 36),
                    FilledButton.icon(
                          key: const Key('back_to_deck_button'),
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Deck'),
                        )
                        .animate()
                        .fadeIn(delay: 350.ms, duration: 300.ms)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          curve: Curves.easeOutBack,
                        ),
                  ],
                ),
              ),
            );
          }

          final currentCard = sessionState.currentCard!;
          final total = sessionState.totalCards;
          final currentNum = sessionState.currentIndex + 1;
          final progress = total > 0 ? currentNum / total : 0.0;
          final controller = ref.read(
            studySessionControllerProvider(deckId).notifier,
          );

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Card $currentNum of $total',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${sessionState.remainingCards} remaining',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: progress),
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          builder: (context, animatedProgress, _) {
                            return LinearProgressIndicator(
                              key: const Key('study_progress_bar'),
                              value: animatedProgress,
                              minHeight: 6,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FlipCardView(
                      card: currentCard,
                      isAnswerRevealed: sessionState.isAnswerRevealed,
                      onCardTap: !sessionState.isAnswerRevealed
                          ? () {
                              final intensity = ref.read(
                                hapticFeedbackControllerProvider,
                              );
                              ref
                                  .read(hapticServiceProvider)
                                  .triggerSelection(intensity);
                              controller.revealAnswer();
                            }
                          : null,
                    ),
                  ),
                ),
                if (!sessionState.isAnswerRevealed)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        key: const Key('show_answer_button'),
                        onPressed: () {
                          final intensity = ref.read(
                            hapticFeedbackControllerProvider,
                          );
                          ref
                              .read(hapticServiceProvider)
                              .triggerSelection(intensity);
                          controller.revealAnswer();
                        },
                        icon: const Icon(Icons.flip_rounded),
                        label: const Text(
                          'Show Answer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 150.ms),
                  )
                else
                  RatingBar(
                    intervals: controller.getIntervalPreviews(),
                    onRatingSelected: (rating) {
                      final haptic = ref.read(hapticServiceProvider);
                      final intensity = ref.read(
                        hapticFeedbackControllerProvider,
                      );
                      haptic.triggerRatingFeedback(rating, intensity);
                      controller.submitRating(rating);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
