import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart' show Deck;
import '../../study_session/presentation/study_screen.dart';
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
    final cardsAsync = ref.watch(cardListControllerProvider(deck.id));

    return Scaffold(
      appBar: AppBar(title: Text(deck.name)),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error loading cards: $error',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
        data: (cards) {
          final now = DateTime.now().toUtc();
          final dueCount = cards.where((c) {
            return c.state == 0 ||
                c.due.isBefore(now) ||
                c.due.isAtSameMomentAs(now);
          }).length;

          return Column(
            children: [
              Container(
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
                          '$dueCount cards due for review',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                      label: const Text('Start Study Session'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Cards (${cards.length})',
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
                        child: Text(
                          'No cards in this deck yet.\nTap + to add one.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return _CardTile(
                            key: ValueKey(card.id),
                            card: card,
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
                                  .read(
                                    cardListControllerProvider(deck.id)
                                        .notifier,
                                  )
                                  .deleteCard(card.id);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_card_fab'),
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
    required this.onEdit,
    required this.onDelete,
  });

  final CardEntity card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _stateName(int state) {
    switch (state) {
      case 0:
        return 'New';
      case 1:
        return 'Learning';
      case 2:
        return 'Review';
      case 3:
        return 'Relearning';
      default:
        return 'Unknown';
    }
  }

  Color _stateColor(int state, ColorScheme scheme) {
    switch (state) {
      case 0:
        return scheme.primary;
      case 1:
        return scheme.tertiary;
      case 2:
        return scheme.secondary;
      case 3:
        return scheme.error;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dismissible(
      key: ValueKey('dismiss_${card.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: scheme.onError),
      ),
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
                        card.front,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _stateColor(
                          card.state,
                          scheme,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _stateName(card.state),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _stateColor(card.state, scheme),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: scheme.error),
                          ),
                        ),
                      ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
