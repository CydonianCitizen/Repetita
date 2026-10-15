import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/theme/app_theme.dart';
import 'package:repetita/src/core/theme/font_theme.dart';
import 'package:repetita/src/features/settings/domain/app_theme_mode.dart';
import 'package:repetita/src/features/settings/presentation/controllers/theme_mode_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme & MaterialTheme Unit Tests', () {
    test('createAppTextTheme combines Lora display and Ubuntu body fonts', () {
      final textTheme = createAppTextTheme();
      expect(textTheme.displayLarge?.fontFamily, contains('Lora'));
      expect(textTheme.headlineMedium?.fontFamily, contains('Lora'));
      expect(textTheme.titleLarge?.fontFamily, contains('Lora'));
      expect(textTheme.bodyLarge?.fontFamily, contains('Ubuntu'));
      expect(textTheme.bodyMedium?.fontFamily, contains('Ubuntu'));
      expect(textTheme.labelLarge?.fontFamily, contains('Ubuntu'));
    });

    test(
      'lightTheme configures Material 3 with MaterialTheme palette and fonts',
      () {
        final theme = AppTheme.lightTheme;

        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.light);
        expect(theme.textTheme.bodyMedium?.fontFamily, contains('Ubuntu'));
        expect(theme.textTheme.titleMedium?.fontFamily, contains('Lora'));
        expect(theme.colorScheme.primary, const Color(0xff6d5e0f));
        expect(theme.colorScheme.surface, const Color(0xfffaf8ff));
        expect(theme.colorScheme.onSurface, const Color(0xff1a1b21));
        expect(theme.appBarTheme.centerTitle, isTrue);
        expect(theme.appBarTheme.elevation, 0);
        expect(theme.cardTheme.elevation, 0);
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      },
    );

    test('darkTheme configures Material 3 with MaterialTheme dark palette', () {
      final theme = AppTheme.darkTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xffdbc66e));
      expect(theme.colorScheme.surface, const Color(0xff121318));
      expect(theme.colorScheme.onSurface, const Color(0xffe3e2e9));
      expect(theme.appBarTheme.centerTitle, isTrue);
      expect(theme.appBarTheme.elevation, 0);
    });

    test('amoledTheme configures Material 3 with pure black surface', () {
      final theme = AppTheme.amoledTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xffdbc66e));
      expect(theme.colorScheme.surface, const Color(0xff000000));
      expect(theme.scaffoldBackgroundColor, const Color(0xff000000));
      expect(theme.canvasColor, const Color(0xff000000));
      expect(theme.appBarTheme.centerTitle, isTrue);
      expect(theme.appBarTheme.elevation, 0);
    });

    test('ThemeModeController initializes to system and transitions modes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeControllerProvider), AppThemeMode.system);

      container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(AppThemeMode.dark);
      expect(container.read(themeModeControllerProvider), AppThemeMode.dark);

      container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(AppThemeMode.amoled);
      expect(container.read(themeModeControllerProvider), AppThemeMode.amoled);

      container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(AppThemeMode.light);
      expect(container.read(themeModeControllerProvider), AppThemeMode.light);

      container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(AppThemeMode.system);
      expect(container.read(themeModeControllerProvider), AppThemeMode.system);
    });
  });
}
