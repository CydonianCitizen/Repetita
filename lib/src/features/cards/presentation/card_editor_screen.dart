import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import 'controllers/card_list_controller.dart';

class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({
    super.key,
    required this.deckId,
    this.cardId,
    this.initialFront,
    this.initialBack,
  });

  final int deckId;
  final int? cardId;
  final String? initialFront;
  final String? initialBack;

  bool get isEditing => cardId != null;

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _frontController;
  late final TextEditingController _backController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.initialFront);
    _backController = TextEditingController(text: widget.initialBack);
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _save({bool addAnother = false}) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final front = _frontController.text.trim();
      final back = _backController.text.trim();

      if (widget.isEditing) {
        await ref
            .read(cardListControllerProvider(widget.deckId).notifier)
            .updateCard(id: widget.cardId!, front: front, back: back);
      } else {
        await ref
            .read(cardListControllerProvider(widget.deckId).notifier)
            .createCard(front: front, back: back);
      }

      if (mounted) {
        if (addAnother) {
          _frontController.clear();
          _backController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.cardSaved ?? 'Card saved',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          Navigator.of(context).pop();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.isEditing
        ? (l10n?.editCard ?? 'Edit Card')
        : (l10n?.newCard ?? 'New Card');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!widget.isEditing)
            TextButton(
              key: const Key('save_and_add_another_button'),
              onPressed: _isSaving ? null : () => _save(addAnother: true),
              child: Text(l10n?.saveAndAddAnother ?? 'Save & Add Another'),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              key: const Key('save_card_button'),
              onPressed: _isSaving ? null : () => _save(addAnother: false),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n?.save ?? 'Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('card_front_field'),
              controller: _frontController,
              autofocus: !widget.isEditing,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                labelText: l10n?.cardFront ?? 'Front (Prompt)',
                hintText: l10n?.promptHint ?? 'Enter question or prompt...',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.frontPromptCannotBeEmpty ??
                      'Front prompt cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('card_back_field'),
              controller: _backController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                labelText: l10n?.cardBack ?? 'Back (Answer)',
                hintText: l10n?.answerHint ?? 'Enter answer...',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.backAnswerCannotBeEmpty ??
                      'Back answer cannot be empty';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
