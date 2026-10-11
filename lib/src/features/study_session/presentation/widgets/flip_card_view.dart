import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../cards/domain/card_entity.dart';

class FlipCardView extends StatefulWidget {
  const FlipCardView({
    super.key,
    required this.card,
    required this.isAnswerRevealed,
    this.onCardTap,
  });

  final CardEntity card;
  final bool isAnswerRevealed;
  final VoidCallback? onCardTap;

  @override
  State<FlipCardView> createState() => _FlipCardViewState();
}

class _FlipCardViewState extends State<FlipCardView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, minHeight: 280),
            child: TweenAnimationBuilder<double>(
              key: ValueKey(widget.card.id),
              tween: Tween<double>(
                begin: 0.0,
                end: widget.isAnswerRevealed ? 1.0 : 0.0,
              ),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              builder: (context, value, child) {
                final isBack = value >= 0.5;
                final angle = value * math.pi;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 3D depth perspective
                    ..rotateY(angle),
                  child: isBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildBackCard(
                            context,
                            colorScheme,
                            theme,
                            l10n,
                          ),
                        )
                      : _buildFrontCard(context, colorScheme, theme, l10n),
                );
              },
            ),
          ),
        )
        .animate(key: ValueKey(widget.card.id))
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildFrontCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Card(
      elevation: 2,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: widget.onCardTap,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n?.promptBadge ?? 'PROMPT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.flip_rounded,
                    size: 18,
                    color: colorScheme.outline.withValues(alpha: 0.6),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Semantics(
                label: 'Card Prompt: ${widget.card.front}',
                readOnly: true,
                child: Text(
                  widget.card.front,
                  key: const Key('card_front_text'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n?.tapToFlipHint ?? 'Tap or press Show Answer to flip',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Card(
      elevation: 3,
      shadowColor: colorScheme.primary.withValues(alpha: 0.12),
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n?.answerBadge ?? 'ANSWER',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: colorScheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.card.front,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Semantics(
              label: 'Card Answer: ${widget.card.back}',
              readOnly: true,
              child: Text(
                widget.card.back,
                key: const Key('card_back_text'),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
