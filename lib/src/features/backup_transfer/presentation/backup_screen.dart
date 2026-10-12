import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../decks/data/decks_dao.dart';
import '../../decks/presentation/controllers/deck_list_controller.dart';
import 'controllers/backup_controller.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  Future<void> _handleExportJson() async {
    try {
      final jsonString = await ref
          .read(backupControllerProvider.notifier)
          .exportJson();

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showResultDialog(
        title: l10n?.fullBackupJson ?? 'Full Backup JSON',
        content: jsonString,
        successMessage:
            l10n?.backupExportedSuccess ?? 'Backup exported successfully!',
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        _showErrorSnackBar('${l10n?.exportFailed ?? "Export failed"}: $e');
      }
    }
  }

  Future<void> _handleRestoreJson() async {
    final result = await showDialog<({String json, bool replaceExisting})>(
      context: context,
      builder: (context) => const _JsonRestoreDialog(),
    );

    if (result != null && result.json.trim().isNotEmpty) {
      if (result.replaceExisting && mounted) {
        final l10n = AppLocalizations.of(context);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n?.restoreBackupTitle ?? 'Confirm Restore'),
            content: Text(
              l10n?.restoreWarning ?? 'Warning: Restoring with "Replace existing" will overwrite all existing decks and cards. Do you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                  foregroundColor: Theme.of(ctx).colorScheme.onError,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n?.restore ?? 'Restore'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }

      try {
        await ref
            .read(backupControllerProvider.notifier)
            .importJson(
              result.json.trim(),
              replaceExisting: result.replaceExisting,
            );
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.backupRestoredSuccess ?? 'Backup restored successfully!',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          _showErrorSnackBar('${l10n?.restoreFailed ?? "Restore failed"}: $e');
        }
      }
    }
  }

  Future<void> _handleExportCsv() async {
    try {
      final csvString = await ref
          .read(backupControllerProvider.notifier)
          .exportCsv();

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      _showResultDialog(
        title: l10n?.exportedCsvTitle ?? 'Exported CSV',
        content: csvString,
        successMessage:
            l10n?.csvExportedSuccess ?? 'CSV exported successfully!',
      );
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        _showErrorSnackBar('${l10n?.exportFailed ?? "Export failed"}: $e');
      }
    }
  }

  Future<void> _handleImportCsv() async {
    final l10n = AppLocalizations.of(context);
    final decks =
        ref.read(deckListControllerProvider).value ?? <DeckWithCounts>[];
    if (decks.isEmpty) {
      _showErrorSnackBar(
        l10n?.createDeckFirstNotice ??
            'Please create a deck first before importing cards.',
      );
      return;
    }

    final result = await showDialog<({int deckId, String csv})>(
      context: context,
      builder: (context) => _CsvImportDialog(decks: decks),
    );

    if (result != null && result.csv.trim().isNotEmpty) {
      try {
        final importResult = await ref
            .read(backupControllerProvider.notifier)
            .importCsv(result.csv.trim(), targetDeckId: result.deckId);
        if (mounted) {
          final snackL10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                snackL10n?.importCardsSuccess(
                      importResult.importedCount,
                      importResult.skippedCount,
                    ) ??
                    'Imported ${importResult.importedCount} cards (${importResult.skippedCount} skipped).',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final errL10n = AppLocalizations.of(context);
          _showErrorSnackBar('${errL10n?.importFailed ?? "Import failed"}: $e');
        }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(backupControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.backupTitle ?? 'Backup & Transfer')),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  icon: Icons.storage,
                  title:
                      l10n?.fullDatabaseBackup ?? 'Full Database Backup (JSON)',
                  description: l10n?.exportDescription ?? 'Export entire study database including all decks, cards, scheduling states, and historical review logs.',
                  actions: [
                    FilledButton.icon(
                      key: const Key('export_json_button'),
                      onPressed: isLoading ? null : _handleExportJson,
                      icon: const Icon(Icons.file_upload_outlined),
                      label: Text(l10n?.exportBackup ?? 'Export Full Backup'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const Key('restore_json_button'),
                      onPressed: isLoading ? null : _handleRestoreJson,
                      icon: const Icon(Icons.file_download_outlined),
                      label: Text(l10n?.restoreJson ?? 'Restore Backup'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  icon: Icons.table_chart_outlined,
                  title:
                      l10n?.flashcardsInterchange ??
                      'Flashcards Interchange (CSV)',
                  description: l10n?.csvSectionDescription ?? 'Export or import cards as CSV with Front and Back fields for interchange with spreadsheets and other tools.',
                  actions: [
                    FilledButton.icon(
                      key: const Key('export_csv_button'),
                      onPressed: isLoading ? null : _handleExportCsv,
                      icon: const Icon(Icons.upload_file),
                      label: Text(l10n?.exportCsv ?? 'Export Cards to CSV'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const Key('import_csv_button'),
                      onPressed: isLoading ? null : _handleImportCsv,
                      icon: const Icon(Icons.download_for_offline_outlined),
                      label: Text(l10n?.importCsv ?? 'Import Cards from CSV'),
                    ),
                  ],
                ),
              ],
            ),
            if (isLoading)
              ColoredBox(
                color: colorScheme.scrim.withValues(alpha: 0.32),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
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
  bool _replaceExisting = false;

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
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.restoreBackupTitle ?? 'Restore Backup'),
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
                _replaceExisting
                    ? (l10n?.restoreWarning ??
                          'Warning: Restoring with "Replace existing" will overwrite all existing decks and cards.')
                    : 'Merging backup data with existing decks and cards.',
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              key: const Key('replace_existing_switch'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Replace existing data'),
              subtitle: Text(
                _replaceExisting
                    ? 'Erase existing decks and start fresh'
                    : 'Keep existing decks and merge data',
                style: theme.textTheme.bodySmall,
              ),
              value: _replaceExisting,
              onChanged: (val) => setState(() => _replaceExisting = val),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('json_input_field'),
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText:
                    l10n?.pasteBackupJsonHint ?? 'Paste backup JSON here...',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          key: const Key('confirm_restore_button'),
          onPressed: () => Navigator.of(context)
              .pop((json: _controller.text, replaceExisting: _replaceExisting)),
          child: Text(l10n?.restore ?? 'Restore'),
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
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n?.importCsvTitle ?? 'Import Cards from CSV'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              key: const Key('deck_dropdown'),
              initialValue: _selectedDeckId,
              decoration: InputDecoration(
                labelText: l10n?.targetDeck ?? 'Target Deck',
                border: const OutlineInputBorder(),
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
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          key: const Key('confirm_import_csv_button'),
          onPressed: () =>
              Navigator.of(context)
                  .pop((deckId: _selectedDeckId, csv: _controller.text)),
          child: Text(l10n?.import ?? 'Import'),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isTruncated = content.length > 4000;
    final preview = isTruncated
        ? '${content.substring(0, 4000)}\n\n... [${(content.length / 1024).toStringAsFixed(1)} KB total - preview truncated]'
        : content;

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: SelectableText(
              preview,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy),
          label: Text(l10n?.copyToClipboard ?? 'Copy to Clipboard'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.copiedToClipboard ?? 'Copied to clipboard!',
                ),
              ),
            );
          },
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.close ?? 'Close'),
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
