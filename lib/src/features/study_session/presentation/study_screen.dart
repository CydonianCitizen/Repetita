import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/study_session_controller.dart';
import 'widgets/flip_card_view.dart';
import 'widgets/rating_bar.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key, required this.deckId});

  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stateAsync = ref.watch(studySessionControllerProvider(deckId));

    return Scaffold(
      appBar: AppBar(title: const Text('Study Session')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error loading study session: $error',
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
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'All cards reviewed for today!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Great job! Check back later for upcoming reviews.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      key: const Key('back_to_deck_button'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Deck'),
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
                        child: LinearProgressIndicator(
                          key: const Key('study_progress_bar'),
                          value: progress,
                          minHeight: 6,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
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
                      child: FilledButton(
                        key: const Key('show_answer_button'),
                        onPressed: () => controller.revealAnswer(),
                        child: const Text(
                          'Show Answer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  RatingBar(
                    intervals: controller.getIntervalPreviews(),
                    onRatingSelected: (rating) =>
                        controller.submitRating(rating),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
