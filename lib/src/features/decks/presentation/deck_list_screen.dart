import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/error_view.dart';
import '../../cards/presentation/deck_detail_screen.dart';
import 'controllers/deck_list_controller.dart';
import 'widgets/deck_form_dialog.dart';
import 'widgets/deck_list_tile.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(deckListControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.appTitle ?? 'repetita')),
      body: SafeArea(
        child: decksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ErrorView(
            title: l10n?.failedToLoadDecks ?? 'Failed to load decks',
            error: error,
            onRetry: () => ref.invalidate(deckListControllerProvider),
          ),
          data: (decks) {
            if (decks.isEmpty) {
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.style_outlined,
                          size: 44,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n?.noDecksYet ??
                            'No decks yet. Tap + to create one.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.createFirstDeckPrompt ?? 'Create your first deck to begin spaced repetition studying.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () async {
                          final result = await DeckFormDialog.show(context);
                          if (result != null) {
                            await ref
                                .read(deckListControllerProvider.notifier)
                                .createDeck(
                                  name: result.name,
                                  description: result.description,
                                );
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n?.newDeck ?? 'New Deck'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deckWithCounts = decks[index];
                return DeckListTile(
                  key: ValueKey(deckWithCounts.deck.id),
                  deckWithCounts: deckWithCounts,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DeckDetailScreen(deck: deckWithCounts.deck),
                      ),
                    );
                  },
                  onEdit: (name, description) async {
                    try {
                      await ref
                          .read(deckListControllerProvider.notifier)
                          .updateDeck(
                            id: deckWithCounts.deck.id,
                            name: name,
                            description: description,
                          );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update deck: $e'),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                        );
                      }
                    }
                  },
                  onDelete: () async {
                    try {
                      await ref
                          .read(deckListControllerProvider.notifier)
                          .deleteDeck(deckWithCounts.deck.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete deck: $e'),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .error,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('create_deck_fab'),
        tooltip: l10n?.createDeck ?? 'Create Deck',
        onPressed: () async {
          final result = await DeckFormDialog.show(context);
          if (result != null) {
            try {
              await ref
                  .read(deckListControllerProvider.notifier)
                  .createDeck(
                    name: result.name,
                    description: result.description,
                  );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create deck: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
