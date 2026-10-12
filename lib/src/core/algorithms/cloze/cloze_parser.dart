import 'dart:math' as math;

import 'cloze_segment.dart';

class ClozeParser {
  const ClozeParser._();

  static final RegExp _clozeRegex = RegExp(
    r'\{\{c(\d+)::(.*?)\}\}',
    dotAll: true,
  );

  /// Checks if [text] contains at least one valid Cloze deletion block.
  static bool isCloze(String text) {
    return _clozeRegex.hasMatch(text);
  }

  /// Extracts all unique Cloze indices found in [text] in ascending order.
  static Set<int> extractClozeIndices(String text) {
    final indices = <int>{};
    for (final match in _clozeRegex.allMatches(text)) {
      final indexStr = match.group(1);
      if (indexStr != null) {
        final parsed = int.tryParse(indexStr);
        if (parsed != null && parsed > 0) {
          indices.add(parsed);
        }
      }
    }
    return indices;
  }

  /// Calculates the next available Cloze index for [text].
  ///
  /// If no Cloze blocks exist, returns 1. Otherwise returns `max(indices) + 1`.
  static int getNextClozeIndex(String text) {
    final indices = extractClozeIndices(text);
    if (indices.isEmpty) return 1;
    return indices.reduce(math.max) + 1;
  }

  /// Parses [text] into segments, distinguishing prompt masking from answer display.
  static List<ClozeSegment> parseSegments(
    String text, {
    int activeIndex = 1,
    required bool isPrompt,
  }) {
    if (!isCloze(text)) {
      return [ClozeSegment(text: text)];
    }

    final segments = <ClozeSegment>[];
    var lastIndex = 0;

    for (final match in _clozeRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        segments.add(
          ClozeSegment(text: text.substring(lastIndex, match.start)),
        );
      }

      final clozeIndex = int.tryParse(match.group(1) ?? '1') ?? 1;
      final inner = match.group(2) ?? '';
      final parsed = _parseInnerContent(inner);
      final isActive = clozeIndex == activeIndex;

      if (isPrompt && isActive) {
        final maskText = parsed.hint != null && parsed.hint!.trim().isNotEmpty
            ? '[${parsed.hint!.trim()}]'
            : '[...]';
        segments.add(
          ClozeSegment(
            text: maskText,
            isCloze: true,
            isActive: true,
            hint: parsed.hint,
          ),
        );
      } else {
        segments.add(
          ClozeSegment(
            text: parsed.answer,
            isCloze: true,
            isActive: isPrompt ? false : isActive,
            hint: parsed.hint,
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      segments.add(ClozeSegment(text: text.substring(lastIndex)));
    }

    return segments;
  }

  /// Parses [text] into prompt segments for display on the front of a flashcard.
  static List<ClozeSegment> getPromptSegments(
    String text, {
    int activeIndex = 1,
  }) => parseSegments(text, activeIndex: activeIndex, isPrompt: true);

  /// Parses [text] into answer segments for display on the back of a flashcard.
  static List<ClozeSegment> getAnswerSegments(
    String text, {
    int activeIndex = 1,
  }) => parseSegments(text, activeIndex: activeIndex, isPrompt: false);

  /// Renders the plain string prompt for the front of a flashcard.
  static String renderClozePrompt(String text, {int activeIndex = 1}) {
    return getPromptSegments(
      text,
      activeIndex: activeIndex,
    ).map((s) => s.text).join();
  }

  /// Renders the plain string answer for the back of a flashcard.
  static String renderClozeAnswer(String text, {int activeIndex = 1}) {
    return getAnswerSegments(
      text,
      activeIndex: activeIndex,
    ).map((s) => s.text).join();
  }

  /// Wraps a range of [text] between [start] and [end] inside a Cloze syntax block.
  ///
  /// If [index] is omitted, defaults to [getNextClozeIndex].
  /// If [hint] is provided, formats as `{{c$index::$selected::$hint}}`.
  static String wrapSelectionWithCloze(
    String text,
    int start,
    int end, {
    int? index,
    String? hint,
  }) {
    final clampedStart = start.clamp(0, text.length);
    final clampedEnd = end.clamp(clampedStart, text.length);
    final clozeIdx = index ?? getNextClozeIndex(text);
    final selectedText = text.substring(clampedStart, clampedEnd);

    final String replacement;
    if (hint != null && hint.trim().isNotEmpty) {
      replacement = '{{c$clozeIdx::$selectedText::${hint.trim()}}}';
    } else {
      replacement = '{{c$clozeIdx::$selectedText}}';
    }

    return text.replaceRange(clampedStart, clampedEnd, replacement);
  }

  static ({String answer, String? hint}) _parseInnerContent(String inner) {
    final separatorIndex = inner.indexOf('::');
    if (separatorIndex == -1) {
      return (answer: inner, hint: null);
    }
    final answer = inner.substring(0, separatorIndex);
    final hint = inner.substring(separatorIndex + 2);
    return (answer: answer, hint: hint.isNotEmpty ? hint : null);
  }
}
