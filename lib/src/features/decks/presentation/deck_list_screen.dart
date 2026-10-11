import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../backup_transfer/presentation/backup_screen.dart';
import '../../cards/presentation/deck_detail_screen.dart';
import '../../stats/presentation/stats_screen.dart';
import 'controllers/deck_list_controller.dart';
import 'widgets/deck_form_dialog.dart';
import 'widgets/deck_list_tile.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(deckListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repetita'),
        actions: [
          IconButton(
            key: const Key('open_stats_button'),
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            key: const Key('open_backup_button'),
            icon: const Icon(Icons.backup_outlined),
            tooltip: 'Backup & Restore',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BackupScreen()),
              );
            },
          ),
        ],
      ),
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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No decks yet. Tap + to create one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
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
