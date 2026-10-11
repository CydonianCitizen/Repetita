import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../decks/data/decks_dao.dart';
import '../../decks/presentation/controllers/deck_list_controller.dart';
import 'controllers/backup_controller.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isLoading = false;

  Future<void> _handleExportJson() async {
    setState(() => _isLoading = true);
    try {
      final jsonString = await ref
          .read(backupControllerProvider.notifier)
          .exportJson();

      if (!mounted) return;
      _showResultDialog(
        title: 'Full Backup JSON',
        content: jsonString,
        successMessage: 'Backup exported successfully!',
      );
    } catch (e) {
      if (mounted) _showErrorSnackBar('Export failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestoreJson() async {
    final jsonText = await showDialog<String>(
      context: context,
      builder: (context) => const _JsonRestoreDialog(),
    );

    if (jsonText != null && jsonText.trim().isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(backupControllerProvider.notifier)
            .importJson(jsonText.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup restored successfully!')),
          );
        }
      } catch (e) {
        if (mounted) _showErrorSnackBar('Restore failed: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleExportCsv() async {
    setState(() => _isLoading = true);
    try {
      final csvString = await ref
          .read(backupControllerProvider.notifier)
          .exportCsv();

      if (!mounted) return;
      _showResultDialog(
        title: 'Exported CSV',
        content: csvString,
        successMessage: 'CSV exported successfully!',
      );
    } catch (e) {
      if (mounted) _showErrorSnackBar('Export failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleImportCsv() async {
    final decks =
        ref.read(deckListControllerProvider).value ?? <DeckWithCounts>[];
    if (decks.isEmpty) {
      _showErrorSnackBar('Please create a deck first before importing cards.');
      return;
    }

    final result = await showDialog<({int deckId, String csv})>(
      context: context,
      builder: (context) => _CsvImportDialog(decks: decks),
    );

    if (result != null && result.csv.trim().isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final importResult = await ref
            .read(backupControllerProvider.notifier)
            .importCardsFromCsv(result.csv.trim(), targetDeckId: result.deckId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Imported ${importResult.importedCount} cards (${importResult.skippedCount} skipped).',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) _showErrorSnackBar('Import failed: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showResultDialog({
    required String title,
    required String content,
    required String successMessage,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          _DisplayResultDialog(title: title, content: content),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(successMessage)));
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Transfer')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionCard(
                icon: Icons.storage,
                title: 'Full Database Backup (JSON)',
                description: 'Export entire study database including all decks, cards, scheduling states, and historical review logs.',
                actions: [
                  FilledButton.icon(
                    key: const Key('export_json_button'),
                    onPressed: _isLoading ? null : _handleExportJson,
                    icon: const Icon(Icons.file_upload_outlined),
                    label: const Text('Export Full Backup'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('restore_json_button'),
                    onPressed: _isLoading ? null : _handleRestoreJson,
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Restore Backup'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionCard(
                icon: Icons.table_chart_outlined,
                title: 'Flashcards Interchange (CSV)',
                description: 'Export or import cards as CSV with Front and Back fields for interchange with spreadsheets and other tools.',
                actions: [
                  FilledButton.icon(
                    key: const Key('export_csv_button'),
                    onPressed: _isLoading ? null : _handleExportCsv,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Export Cards to CSV'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('import_csv_button'),
                    onPressed: _isLoading ? null : _handleImportCsv,
                    icon: const Icon(Icons.download_for_offline_outlined),
                    label: const Text('Import Cards from CSV'),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _JsonRestoreDialog extends StatefulWidget {
  const _JsonRestoreDialog();

  @override
  State<_JsonRestoreDialog> createState() => _JsonRestoreDialogState();
}

class _JsonRestoreDialogState extends State<_JsonRestoreDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Restore Backup'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Warning: Restoring a backup will overwrite all existing decks and cards.',
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('json_input_field'),
              controller: _controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Paste backup JSON here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('confirm_restore_button'),
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Restore'),
        ),
      ],
    );
  }
}

class _CsvImportDialog extends StatefulWidget {
  const _CsvImportDialog({required this.decks});

  final List<DeckWithCounts> decks;

  @override
  State<_CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<_CsvImportDialog> {
  late int _selectedDeckId;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedDeckId = widget.decks.first.deck.id;
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Cards from CSV'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              key: const Key('deck_dropdown'),
              initialValue: _selectedDeckId,
              decoration: const InputDecoration(
                labelText: 'Target Deck',
                border: OutlineInputBorder(),
              ),
              items: widget.decks.map((d) {
                return DropdownMenuItem<int>(
                  value: d.deck.id,
                  child: Text(d.deck.name),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedDeckId = val);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('csv_input_field'),
              controller: _controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Front,Back\nWhat is DNA?,Genetic material',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('confirm_import_csv_button'),
          onPressed: () =>
              Navigator.of(context)
                  .pop((deckId: _selectedDeckId, csv: _controller.text)),
          child: const Text('Import'),
        ),
      ],
    );
  }
}

class _DisplayResultDialog extends StatelessWidget {
  const _DisplayResultDialog({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(child: SelectableText(content)),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text('Copy to Clipboard'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard!')),
            );
          },
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ...actions,
          ],
        ),
      ),
    );
  }
}
