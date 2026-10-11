import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/features/settings/presentation/settings_screen.dart';

void main() {
  Widget buildSubject() {
    return const MaterialApp(home: SettingsScreen());
  }

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders all settings sections, tiles, and branding', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildSubject());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Repetita'), findsOneWidget);
      expect(find.textContaining('v0.0.5'), findsWidgets);

      // Section headers
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('LANGUAGE & LOCALIZATION'), findsOneWidget);
      expect(find.text('STUDY & ALGORITHM'), findsOneWidget);
      expect(find.text('UPDATES & RELEASES'), findsOneWidget);
      expect(find.text('ABOUT & PRIVACY'), findsOneWidget);

      // Tiles
      expect(find.byKey(const Key('setting_theme_tile')), findsOneWidget);
      expect(find.byKey(const Key('setting_language_tile')), findsOneWidget);
      expect(find.byKey(const Key('setting_fsrs_tile')), findsOneWidget);
      expect(
        find.byKey(const Key('setting_github_update_tile')),
        findsOneWidget,
      );
    });

    testWidgets(
      'tapping Language tile opens placeholder language selector dialog',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildSubject());

        await tester.tap(find.byKey(const Key('setting_language_tile')));
        await tester.pumpAndSettle();

        expect(find.text('Select Language'), findsOneWidget);
        expect(find.text('English (Default)'), findsOneWidget);
        expect(find.text('Italiano'), findsOneWidget);
        expect(find.text('Español'), findsOneWidget);

        // Tap Italiano
        await tester.tap(find.text('Italiano'));
        await tester.pumpAndSettle();

        expect(find.text('Select Language'), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets('tapping Theme tile opens placeholder theme selector dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byKey(const Key('setting_theme_tile')));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AlertDialog, 'Theme Mode'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Dark Theme'), findsOneWidget);
      expect(find.text('Light Theme'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tapping Check for Updates shows update status dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byKey(const Key('setting_github_update_tile')));
      await tester.pumpAndSettle();

      expect(find.text('Up to Date'), findsOneWidget);
      expect(
        find.textContaining('Repetita is currently running the latest version'),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Up to Date'), findsNothing);
    });
  });
}
