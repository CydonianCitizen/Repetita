import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/backup_transfer/domain/services/anki_html_sanitizer.dart';

void main() {
  group('AnkiHtmlSanitizer Unit Tests', () {
    test('returns empty string for empty input', () {
      expect(AnkiHtmlSanitizer.sanitize(''), equals(''));
    });

    test('preserves plain text without modification', () {
      expect(AnkiHtmlSanitizer.sanitize('Hello World'), equals('Hello World'));
    });

    test('converts <br> and <br/> tags to newlines', () {
      expect(
        AnkiHtmlSanitizer.sanitize('Line 1<br>Line 2<br/>Line 3<br />Line 4'),
        equals('Line 1\nLine 2\nLine 3\nLine 4'),
      );
    });

    test('converts <div> and <p> block tags to newlines', () {
      expect(
        AnkiHtmlSanitizer.sanitize(
          '<div>First line</div><div>Second line</div>',
        ),
        equals('First line\nSecond line'),
      );
      expect(
        AnkiHtmlSanitizer.sanitize('<p>Paragraph 1</p><p>Paragraph 2</p>'),
        equals('Paragraph 1\nParagraph 2'),
      );
    });

    test('converts bold and italic tags to markdown', () {
      expect(
        AnkiHtmlSanitizer.sanitize('<b>Important</b> and <i>subtle</i>'),
        equals('**Important** and *subtle*'),
      );
      expect(
        AnkiHtmlSanitizer.sanitize(
          '<strong>Strong</strong> and <em>emphasis</em>',
        ),
        equals('**Strong** and *emphasis*'),
      );
    });

    test('strips arbitrary HTML tags like span, font, table', () {
      expect(
        AnkiHtmlSanitizer.sanitize(
          '<span style="color:red">Colored text</span> in <font size="4">big font</font>',
        ),
        equals('Colored text in big font'),
      );
    });

    test('removes <style> and <script> contents entirely', () {
      const input =
          '<style>.card { color: blue; }</style><script>alert(1);</script>Content';
      expect(AnkiHtmlSanitizer.sanitize(input), equals('Content'));
    });

    test('decodes HTML entities including named, decimal, and hex', () {
      expect(
        AnkiHtmlSanitizer.sanitize(
          'Rock &amp; Roll &lt;5&gt; &quot;quote&quot; &#39;apostrophe&#39;',
        ),
        equals('Rock & Roll <5> "quote" \'apostrophe\''),
      );
      expect(
        AnkiHtmlSanitizer.sanitize('Space&nbsp;here and &#160;and &#x20;test'),
        equals('Space here and  and  test'),
      );
    });

    test('preserves Cloze deletion syntax completely intact', () {
      const input =
          '<div>{{c1::Photosynthesis}} is the process by which {{c2::plants::flora}} produce energy.</div>';
      expect(
        AnkiHtmlSanitizer.sanitize(input),
        equals(
          '{{c1::Photosynthesis}} is the process by which {{c2::plants::flora}} produce energy.',
        ),
      );
    });

    test('normalizes excessive newlines and trims whitespace', () {
      const input = '  Start  \n\n\n\n\n  <div>Middle</div>  \n\n\n\n  End  ';
      expect(
        AnkiHtmlSanitizer.sanitize(input),
        equals('Start\n\nMiddle\n\nEnd'),
      );
    });
  });
}
