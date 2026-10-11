import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> _save() async {
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
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Card' : 'New Card'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              key: const Key('save_card_button'),
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
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
              decoration: const InputDecoration(
                labelText: 'Front (Prompt)',
                hintText: 'Enter question or prompt...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Front prompt cannot be empty';
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
              decoration: const InputDecoration(
                labelText: 'Back (Answer)',
                hintText: 'Enter answer...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Back answer cannot be empty';
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
