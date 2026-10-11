import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
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
      body: decksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.failedToLoadDecks ?? 'Failed to load decks',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () => ref.invalidate(deckListControllerProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n?.retry ?? 'Retry'),
                ),
              ],
            ),
          ),
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
                      l10n?.noDecksYet ?? 'No decks yet. Tap + to create one.',
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
                onEdit: (name, description) {
                  ref
                      .read(deckListControllerProvider.notifier)
                      .updateDeck(
                        id: deckWithCounts.deck.id,
                        name: name,
                        description: description,
                      );
                },
                onDelete: () {
                  ref
                      .read(deckListControllerProvider.notifier)
                      .deleteDeck(deckWithCounts.deck.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('create_deck_fab'),
        tooltip: l10n?.createDeck ?? 'Create Deck',
        onPressed: () async {
          final result = await DeckFormDialog.show(context);
          if (result != null) {
            await ref
                .read(deckListControllerProvider.notifier)
                .createDeck(name: result.name, description: result.description);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
