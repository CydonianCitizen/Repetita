import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repetita/src/core/theme/app_theme.dart';
import 'package:repetita/src/core/theme/material_theme.dart';
import 'package:repetita/src/features/settings/presentation/controllers/theme_mode_controller.dart';

void main() {
  group('AppTheme & MaterialTheme Unit Tests', () {
    test('lightTheme configures Material 3 with MaterialTheme palette', () {
      final theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, const Color(0xff6d5e0f));
      expect(theme.colorScheme.surface, const Color(0xfffaf8ff));
      expect(theme.colorScheme.onSurface, const Color(0xff1a1b21));
      expect(theme.appBarTheme.centerTitle, isTrue);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
    });

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

    test('contrast variants provide proper brightness schemes', () {
      expect(AppTheme.lightMediumContrastTheme.brightness, Brightness.light);
      expect(AppTheme.lightHighContrastTheme.brightness, Brightness.light);
      expect(AppTheme.darkMediumContrastTheme.brightness, Brightness.dark);
      expect(AppTheme.darkHighContrastTheme.brightness, Brightness.dark);

      expect(
        MaterialTheme.lightMediumContrastScheme().primary,
        const Color(0xff403600),
      );
      expect(
        MaterialTheme.darkHighContrastScheme().primary,
        const Color(0xfffff0ba),
      );
    });

    test('ThemeModeController initializes to system and transitions modes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeControllerProvider), ThemeMode.system);

      container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeControllerProvider), ThemeMode.dark);

      container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.light);
      expect(container.read(themeModeControllerProvider), ThemeMode.light);

      container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.system);
      expect(container.read(themeModeControllerProvider), ThemeMode.system);
    });
  });
}
