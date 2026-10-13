/// Pure Dart utility to clean HTML formatting from Anki notes
/// while preserving Cloze deletion syntax and plain text readability.
class AnkiHtmlSanitizer {
  const AnkiHtmlSanitizer._();

  static final RegExp _scriptStyleRegex = RegExp(
    r'<(script|style)[^>]*>[\s\S]*?<\/\1>',
    caseSensitive: false,
  );

  static final RegExp _brRegex = RegExp(r'<br\s*\/?>', caseSensitive: false);
  static final RegExp _blockCloseRegex = RegExp(
    r'<\/(p|div|li|tr|h[1-6])>',
    caseSensitive: false,
  );
  static final RegExp _blockOpenRegex = RegExp(
    r'<(p|div|li|tr|h[1-6])[^>]*>',
    caseSensitive: false,
  );

  static final RegExp _boldOpenRegex = RegExp(
    r'<(b|strong)[^>]*>',
    caseSensitive: false,
  );
  static final RegExp _boldCloseRegex = RegExp(
    r'<\/(b|strong)>',
    caseSensitive: false,
  );

  static final RegExp _italicOpenRegex = RegExp(
    r'<(i|em)[^>]*>',
    caseSensitive: false,
  );
  static final RegExp _italicCloseRegex = RegExp(
    r'<\/(i|em)>',
    caseSensitive: false,
  );

  static final RegExp _anyTagRegex = RegExp(r'<[^>]+>');
  static final RegExp _multiNewlineRegex = RegExp(r'\n{3,}');

  static final RegExp _decimalEntityRegex = RegExp(r'&#(\d+);');
  static final RegExp _hexEntityRegex = RegExp(r'&#x([0-9a-fA-F]+);');

  /// Sanitizes raw Anki HTML string into clean text/markdown format.
  static String sanitize(String html) {
    if (html.isEmpty) return '';

    String text = html;

    // 1. Remove <script> and <style> blocks entirely
    text = text.replaceAll(_scriptStyleRegex, '');

    // 2. Convert line break tags to newline
    text = text.replaceAll(_brRegex, '\n');

    // 3. Convert block endings to newline
    text = text.replaceAll(_blockCloseRegex, '\n');
    text = text.replaceAll(_blockOpenRegex, '');

    // 4. Convert bold and italic tags to markdown
    text = text.replaceAll(_boldOpenRegex, '**');
    text = text.replaceAll(_boldCloseRegex, '**');
    text = text.replaceAll(_italicOpenRegex, '*');
    text = text.replaceAll(_italicCloseRegex, '*');

    // 5. Strip all remaining HTML tags
    text = text.replaceAll(_anyTagRegex, '');

    // 6. Decode common HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'");

    // Decode decimal entities (e.g. &#160;)
    text = text.replaceAllMapped(_decimalEntityRegex, (match) {
      final code = int.tryParse(match.group(1)!);
      if (code != null && code > 0 && code <= 0x10FFFF) {
        return String.fromCharCode(code);
      }
      return match.group(0)!;
    });

    // Decode hex entities (e.g. &#x20;)
    text = text.replaceAllMapped(_hexEntityRegex, (match) {
      final code = int.tryParse(match.group(1)!, radix: 16);
      if (code != null && code > 0 && code <= 0x10FFFF) {
        return String.fromCharCode(code);
      }
      return match.group(0)!;
    });

    // Replace non-breaking space characters
    text = text.replaceAll('\u00A0', ' ');

    // 7. Normalize multi-newlines and trim whitespace per line
    text = text
        .split('\n')
        .map((line) => line.trim())
        .join('\n')
        .replaceAll(_multiNewlineRegex, '\n\n')
        .trim();

    return text;
  }
}
