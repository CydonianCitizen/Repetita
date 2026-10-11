import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../tags/domain/tag_entity.dart';
import '../../../tags/presentation/controllers/tags_controller.dart';
import '../../domain/models/custom_study_config.dart';

class CustomStudyDialog extends ConsumerStatefulWidget {
  const CustomStudyDialog({
    super.key,
    required this.deckId,
    this.initialTags = const [],
  });

  final int deckId;
  final List<TagEntity> initialTags;

  static Future<CustomStudyConfig?> show(
    BuildContext context, {
    required int deckId,
    List<TagEntity> initialTags = const [],
  }) {
    return showDialog<CustomStudyConfig>(
      context: context,
      builder: (context) =>
          CustomStudyDialog(deckId: deckId, initialTags: initialTags),
    );
  }

  @override
  ConsumerState<CustomStudyDialog> createState() => _CustomStudyDialogState();
}

class _CustomStudyDialogState extends ConsumerState<CustomStudyDialog> {
  CustomStudyScope _scope = CustomStudyScope.allCards;
  int _daysAhead = 1;
  int? _selectedTagId;
  bool _isCram = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialTags.isNotEmpty) {
      _selectedTagId = widget.initialTags.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final deckTagsAsync = ref.watch(deckTagsProvider(widget.deckId));
    final tagsMap = deckTagsAsync.value ?? {};
    final deckTags = {
      for (final t in widget.initialTags) t.id: t,
      for (final list in tagsMap.values)
        for (final tag in list) tag.id: tag,
    }.values.toList();

    if (_selectedTagId == null && deckTags.isNotEmpty) {
      _selectedTagId = deckTags.first.id;
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.tune_rounded, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(l10n?.customStudy ?? 'Custom Study'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.customStudyScope ?? 'Study Scope',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<CustomStudyScope>(
              key: const Key('custom_study_scope_segmented'),
              segments: [
                ButtonSegment(
                  value: CustomStudyScope.allCards,
                  label: Text(l10n?.customStudyAllCards ?? 'All'),
                  icon: const Icon(Icons.all_inclusive, size: 16),
                ),
                ButtonSegment(
                  value: CustomStudyScope.reviewAhead,
                  label: Text(l10n?.customStudyAhead ?? 'Ahead'),
                  icon: const Icon(Icons.fast_forward_rounded, size: 16),
                ),
                ButtonSegment(
                  value: CustomStudyScope.byTag,
                  label: Text(l10n?.tags ?? 'Tag'),
                  icon: const Icon(Icons.label_outline, size: 16),
                ),
              ],
              selected: {_scope},
              onSelectionChanged: (newSelection) {
                setState(() => _scope = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            if (_scope == CustomStudyScope.reviewAhead) ...[
              Text(
                l10n?.customStudyDaysAhead ?? 'Days in advance:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [1, 2, 3, 7].map((days) {
                  return ChoiceChip(
                    key: Key('days_ahead_chip_$days'),
                    label: Text(
                      l10n?.customStudyDays(days) ??
                          '$days ${days == 1 ? "day" : "days"}',
                    ),
                    selected: _daysAhead == days,
                    onSelected: (selected) {
                      if (selected) setState(() => _daysAhead = days);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ] else if (_scope == CustomStudyScope.byTag) ...[
              if (deckTags.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n?.noTagsInDeck ?? 'No tags found in this deck.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                )
              else ...[
                Text(
                  l10n?.selectTag ?? 'Select tag:',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: deckTags.map((tag) {
                    return ChoiceChip(
                      key: Key('custom_study_tag_${tag.id}'),
                      label: Text(tag.name),
                      selected: _selectedTagId == tag.id,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedTagId = tag.id);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ],
            const Divider(),
            SwitchListTile.adaptive(
              key: const Key('cram_mode_switch'),
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n?.cramModeTitle ?? 'Cram Mode (Free Practice)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _isCram
                    ? (l10n?.cramModeDesc ??
                          'Practice cards without affecting FSRS intervals or review logs')
                    : (l10n?.advanceReviewDesc ??
                          'Update FSRS intervals and save reviews normally'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: _isCram,
              onChanged: (val) => setState(() => _isCram = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton.icon(
          key: const Key('confirm_custom_study_button'),
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n?.start ?? 'Start'),
          onPressed:
              (_scope == CustomStudyScope.byTag &&
                  (_selectedTagId == null || deckTags.isEmpty))
              ? null
              : () {
                  final config = CustomStudyConfig(
                    scope: _scope,
                    tagId: _scope == CustomStudyScope.byTag
                        ? _selectedTagId
                        : null,
                    daysAhead: _daysAhead,
                    isCram: _isCram,
                  );
                  Navigator.of(context).pop(config);
                },
        ),
      ],
    );
  }
}
