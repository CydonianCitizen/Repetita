import 'package:flutter/material.dart';

class DeckFormDialog extends StatefulWidget {
  const DeckFormDialog({super.key, this.initialName, this.initialDescription});

  final String? initialName;
  final String? initialDescription;

  static Future<({String name, String? description})?> show(
    BuildContext context, {
    String? initialName,
    String? initialDescription,
  }) {
    return showDialog<({String name, String? description})>(
      context: context,
      builder: (context) => DeckFormDialog(
        initialName: initialName,
        initialDescription: initialDescription,
      ),
    );
  }

  @override
  State<DeckFormDialog> createState() => _DeckFormDialogState();
}

class _DeckFormDialogState extends State<DeckFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final desc = _descriptionController.text.trim();
      Navigator.of(context)
          .pop((name: name, description: desc.isEmpty ? null : desc));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Deck' : 'Create Deck'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('deck_name_field'),
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Deck Name',
                  hintText: 'e.g., Biology 101',
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Deck name is required';
                  }
                  if (trimmed.length > 100) {
                    return 'Name must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('deck_description_field'),
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Optional description of this deck',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('deck_form_submit_button'),
          onPressed: _submit,
          child: Text(_isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
