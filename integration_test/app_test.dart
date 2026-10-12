import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repetita/src/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end user journey', () {
    testWidgets('create deck, add card, study, verify review log',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: RepetitaApp()),
      );
      await tester.pumpAndSettle();

      // TODO: Implement full E2E flow:
      // 1. Create a new deck
      // 2. Add a flashcard
      // 3. Start study session
      // 4. Rate the card
      // 5. Verify review log was recorded
      // 6. Export and verify backup
      expect(find.byType(RepetitaApp), findsOneWidget);
    });
  });
}
