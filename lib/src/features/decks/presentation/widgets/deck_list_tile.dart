import 'package:flutter/material.dart';

import '../../data/decks_dao.dart';
import 'deck_form_dialog.dart';

class DeckListTile extends StatelessWidget {
  const DeckListTile({
    super.key,
    required this.deckWithCounts,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  final DeckWithCounts deckWithCounts;
  final void Function(String name, String? description) onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck?'),
        content: Text(
          'Are you sure you want to delete "${deckWithCounts.deck.name}"? All cards in this deck will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        onDelete();
      }
    });
  }

  void _showEditDialog(BuildContext context) {
    DeckFormDialog.show(
      context,
      initialName: deckWithCounts.deck.name,
      initialDescription: deckWithCounts.deck.description,
    ).then((result) {
      if (result != null) {
        onEdit(result.name, result.description);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deck = deckWithCounts.deck;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deck.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (deck.description != null &&
                            deck.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            deck.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Badge(
                    label: 'Due',
                    count: deckWithCounts.dueCards,
                    backgroundColor: deckWithCounts.dueCards > 0
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    textColor: deckWithCounts.dueCards > 0
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  _Badge(
                    label: 'Total',
                    count: deckWithCounts.totalCards,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    textColor: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.count,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final int count;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $count',
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
