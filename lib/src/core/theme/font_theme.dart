import 'package:flutter/material.dart';

/// Constructs a cohesive Material 3 [TextTheme] combining Lora for display/headings
/// and Ubuntu for body/labels using local offline bundled font assets.
TextTheme createAppTextTheme({Brightness brightness = Brightness.light}) {
  final baseTextTheme = brightness == Brightness.dark
      ? Typography.material2021().white
      : Typography.material2021().black;

  final bodyTextTheme = baseTextTheme.apply(fontFamily: 'Ubuntu');
  final displayTextTheme = baseTextTheme.apply(fontFamily: 'Lora');

  return displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
}
