import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/algorithms/cloze/cloze_parser.dart';
import '../../../core/database/app_database.dart' show Deck;
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/card_state_colors.dart';
import '../../study_session/presentation/study_screen.dart';
import '../../study_session/presentation/widgets/custom_study_dialog.dart';
import '../../tags/domain/tag_entity.dart';
import '../../tags/presentation/controllers/tags_controller.dart';
import '../domain/card_entity.dart';
import 'card_editor_screen.dart';
import 'controllers/card_list_controller.dart';

class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({super.key, required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final cardsAsync = ref.watch(cardListControllerProvider(deck.id));
    final deckTagsAsync = ref.watch(deckTagsProvider(deck.id));

    return Scaffold(
      appBar: AppBar(title: Text(deck.name)),
      body: cardsAsync.when(
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
                  'Error loading cards',
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
                      ref.invalidate(cardListControllerProvider(deck.id)),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n?.retry ?? 'Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (cards) {
          final cardTagsMap = deckTagsAsync.value ?? <int, List<TagEntity>>{};
          final allDeckTags =
              cardTagsMap.values
                  .expand((tags) => tags)
                  .fold<Map<int, TagEntity>>({}, (map, tag) {
                    map[tag.id] = tag;
                    return map;
                  })
                  .values
                  .toList()
                ..sort((a, b) => a.name.compareTo(b.name));

          final now = DateTime.now().toUtc();
          final dueCount = cards.where((c) => c.isDue(now)).length;

          return Column(
            children: [
              _DeckStudyHeader(
                deck: deck,
                cards: cards,
                dueCount: dueCount,
                allDeckTags: allDeckTags,
              ),
              Expanded(
                child: _DeckCardsSection(
                  deck: deck,
                  cards: cards,
                  allDeckTags: allDeckTags,
                  cardTagsMap: cardTagsMap,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_card_fab'),
        tooltip: l10n?.addCard ?? 'Add Card',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CardEditorScreen(deckId: deck.id),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    super.key,
    required this.card,
    this.tags = const [],
    required this.onEdit,
    required this.onDelete,
    required this.onToggleSuspend,
    required this.onToggleBury,
  });

  final CardEntity card;
  final List<TagEntity> tags;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleSuspend;
  final VoidCallback onToggleBury;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: ValueKey('dismiss_${card.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: scheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n?.delete ?? 'Delete'),
                content: Text(
                  l10n?.deleteCardConfirmation ??
                      'Are you sure you want to delete this card?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(l10n?.cancel ?? 'Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(l10n?.delete ?? 'Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        card.isCloze
                            ? ClozeParser.renderClozePrompt(
                                card.front,
                                activeIndex: card.activeClozeIndex,
                              )
                            : card.front,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (card.isCloze)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n?.clozeBadge(card.activeClozeIndex) ??
                                  'Cloze c${card.activeClozeIndex}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (card.isSuspended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n?.suspendedBadge ?? 'Suspended',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (card.isBuried(DateTime.now().toUtc()))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n?.buriedBadge ?? 'Buried',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme
                                .cardStateColor(card.state)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cardStateName(card.state, l10n),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.cardStateColor(card.state),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'suspend') onToggleSuspend();
                        if (value == 'bury') onToggleBury();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) {
                        final itemL10n = AppLocalizations.of(context);
                        final isBuried = card.isBuried(DateTime.now().toUtc());
                        return [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(itemL10n?.edit ?? 'Edit'),
                          ),
                          PopupMenuItem(
                            value: 'suspend',
                            child: Text(
                              card.isSuspended
                                  ? (itemL10n?.unsuspendCard ??
                                        'Unsuspend Card')
                                  : (itemL10n?.suspendCard ?? 'Suspend Card'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'bury',
                            child: Text(
                              isBuried
                                  ? (itemL10n?.unburyCard ?? 'Unbury Card')
                                  : (itemL10n?.buryCard ?? 'Bury Card'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              itemL10n?.delete ?? 'Delete',
                              style: TextStyle(color: scheme.error),
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  card.back,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags.map((tag) {
                      final tagColor = tag.color != 0
                          ? Color(tag.color)
                          : scheme.secondary;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: tagColor.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '#${tag.name}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tagColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (card.state == 0)
                      Text(
                        'New card • Unreviewed',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                      )
                    else ...[
                      Text(
                        'S: ${card.stability.toStringAsFixed(1)}d',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'D: ${card.difficulty.toStringAsFixed(1)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reps: ${card.reps}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckStudyHeader extends StatelessWidget {
  const _DeckStudyHeader({
    required this.deck,
    required this.cards,
    required this.dueCount,
    required this.allDeckTags,
  });

  final Deck deck;
  final List<CardEntity> cards;
  final int dueCount;
  final List<TagEntity> allDeckTags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                l10n?.cardsDueForReview(dueCount) ??
                    '$dueCount cards due for review',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const Key('start_study_button'),
                onPressed: dueCount > 0
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StudyScreen(deckId: deck.id),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n?.startStudySession ?? 'Start Study Session'),
              ),
              OutlinedButton.icon(
                key: const Key('custom_study_button'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onPrimaryContainer,
                  side: BorderSide(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                onPressed: cards.isEmpty
                    ? null
                    : () async {
                        final config = await CustomStudyDialog.show(
                          context,
                          deckId: deck.id,
                          initialTags: allDeckTags,
                        );
                        if (config != null && context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StudyScreen(
                                deckId: deck.id,
                                customStudyConfig: config,
                              ),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.tune_rounded),
                label: Text(l10n?.customStudy ?? 'Custom Study'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeckCardsSection extends ConsumerWidget {
  const _DeckCardsSection({
    required this.deck,
    required this.cards,
    required this.allDeckTags,
    required this.cardTagsMap,
  });

  final Deck deck;
  final List<CardEntity> cards;
  final List<TagEntity> allDeckTags;
  final Map<int, List<TagEntity>> cardTagsMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final selectedTagId = ref.watch(deckTagFilterProvider);

    final displayedCards = selectedTagId == null
        ? cards
        : cards
              .where(
                (c) =>
                    cardTagsMap[c.id]?.any((t) => t.id == selectedTagId) ??
                    false,
              )
              .toList();

    return Column(
      children: [
        if (allDeckTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allDeckTags.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: const Key('filter_tag_all'),
                        label: Text(l10n?.filterAll ?? 'All'),
                        selected: selectedTagId == null,
                        onSelected: (_) => ref
                            .read(deckTagFilterProvider.notifier)
                            .selectTag(null),
                      ),
                    );
                  }
                  final tag = allDeckTags[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      key: Key('filter_tag_${tag.id}'),
                      label: Text('#${tag.name}'),
                      selected: selectedTagId == tag.id,
                      onSelected: (selected) => ref
                          .read(deckTagFilterProvider.notifier)
                          .selectTag(selected ? tag.id : null),
                    ),
                  );
                },
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Cards (${displayedCards.length}${selectedTagId != null ? ' / ${cards.length}' : ''})',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: cards.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.post_add_rounded,
                            size: 36,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cards in this deck yet.\nTap + to add one.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    CardEditorScreen(deckId: deck.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n?.addCard ?? 'Add Card'),
                        ),
                      ],
                    ),
                  ),
                )
              : displayedCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.label_off_outlined,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No cards match this tag.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref
                            .read(deckTagFilterProvider.notifier)
                            .selectTag(null),
                        child: Text(l10n?.filterAll ?? 'Show all cards'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  scrollCacheExtent: const ScrollCacheExtent.pixels(500.0),
                  padding: const EdgeInsets.only(bottom: 80),
                  findChildIndexCallback: (Key key) {
                    if (key is ValueKey<int>) {
                      final idx = displayedCards.indexWhere(
                        (c) => c.id == key.value,
                      );
                      return idx >= 0 ? idx : null;
                    }
                    return null;
                  },
                  itemCount: displayedCards.length,
                  itemBuilder: (context, index) {
                    final card = displayedCards[index];
                    final cardTags =
                        cardTagsMap[card.id] ?? const <TagEntity>[];
                    return _CardTile(
                      key: ValueKey(card.id),
                      card: card,
                      tags: cardTags,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CardEditorScreen(
                              deckId: deck.id,
                              cardId: card.id,
                              initialFront: card.front,
                              initialBack: card.back,
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        ref
                            .read(cardListControllerProvider(deck.id).notifier)
                            .deleteCard(card.id);
                      },
                      onToggleSuspend: () {
                        ref
                            .read(cardListControllerProvider(deck.id).notifier)
                            .toggleSuspendCard(card.id, card.isSuspended);
                      },
                      onToggleBury: () {
                        final now = DateTime.now().toUtc();
                        final notifier = ref.read(
                          cardListControllerProvider(deck.id).notifier,
                        );
                        if (card.isBuried(now)) {
                          notifier.unburyCard(card.id);
                        } else {
                          notifier.buryCard(card.id);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
