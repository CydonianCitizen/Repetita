import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/database/app_database.dart';
import 'package:repetita/src/core/l10n/generated/app_localizations.dart';
import 'package:repetita/src/features/cards/data/cards_dao.dart';
import 'package:repetita/src/core/database/database_provider.dart';
import 'package:repetita/src/features/cards/domain/card_entity.dart';
import 'package:repetita/src/features/cards/presentation/card_editor_screen.dart';
import 'package:repetita/src/features/study_session/presentation/widgets/flip_card_view.dart';

void main() {
  Widget buildSubject({required Widget child, ProviderContainer? container}) {
    return UncontrolledProviderScope(
      container: container ?? ProviderContainer(),
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('Cloze Integration Widget Tests', () {
    testWidgets(
      'FlipCardView renders cloze prompt masked on front and revealed on back',
      (tester) async {
        final clozeCard = CardEntity(
          id: 1,
          deckId: 10,
          front: 'La capitale della Francia è {{c1::Parigi::capitale}}.',
          back: 'Nota storica.',
          state: 0,
          stability: 0,
          difficulty: 0,
          due: DateTime.now().toUtc(),
          reps: 0,
          lapses: 0,
          createdAt: DateTime.now().toUtc(),
        );

        await tester.pumpWidget(
          buildSubject(
            child: FlipCardView(card: clozeCard, isAnswerRevealed: false),
          ),
        );
        await tester.pumpAndSettle();

        // Front displays mask [capitale]
        expect(find.textContaining('[capitale]'), findsOneWidget);
        expect(find.text('Cloze c1'), findsOneWidget);
        expect(find.text('Parigi'), findsNothing);

        // Flip to back
        await tester.pumpWidget(
          buildSubject(
            child: FlipCardView(card: clozeCard, isAnswerRevealed: true),
          ),
        );
        await tester.pumpAndSettle();

        // Back displays revealed answer in card_back_text and extra note
        final backWidget = tester.widget<Text>(
          find.byKey(const Key('card_back_text')),
        );
        expect(backWidget.textSpan?.toPlainText(), contains('Parigi'));
        expect(find.text('Nota storica.'), findsOneWidget);
      },
    );

    testWidgets(
      'CardEditorScreen cloze toolbar inserts {{c1::}} and allows save without back text',
      (tester) async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        await db
            .into(db.decks)
            .insert(DecksCompanion.insert(name: 'Test Deck'));
        final cardsDao = CardsDao(db);
        final container = ProviderContainer(
          overrides: [cardsDaoProvider.overrideWithValue(cardsDao)],
        );
        addTearDown(() {
          container.dispose();
          db.close();
        });

        await tester.pumpWidget(
          buildSubject(
            container: container,
            child: const CardEditorScreen(deckId: 1),
          ),
        );
        await tester.pumpAndSettle();

        // Enter front text
        await tester.enterText(
          find.byKey(const Key('card_front_field')),
          'Canberra è la capitale.',
        );
        await tester.pumpAndSettle();

        // Tap cloze button
        await tester.tap(find.byKey(const Key('insert_cloze_button')));
        await tester.pumpAndSettle();

        // Verifies text has {{c1::}} and Cloze badge appears
        expect(find.textContaining('1 Cloze'), findsOneWidget);

        // Leave back field empty and tap save button
        await tester.tap(find.byKey(const Key('save_card_button')));
        await tester.pumpAndSettle();

        // Card should be created in DB despite empty back
        final cards = await cardsDao.getCardsByDeck(1);
        expect(cards, hasLength(1));
        expect(cards.first.front, contains('{{c1::'));
      },
    );
  });
}
