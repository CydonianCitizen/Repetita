import 'package:flutter/material.dart';

enum AppThemeMode {
  system,
  dark,
  light,
  amoled;

  ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
    }
  }

  bool get isAmoled => this == AppThemeMode.amoled;
}
