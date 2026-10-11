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
          child: Text(
            'Failed to load decks: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        data: (decks) {
          if (decks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n?.noDecksYet ?? 'No decks yet. Tap + to create one.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
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
