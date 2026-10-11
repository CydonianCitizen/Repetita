import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repetita/src/core/theme/app_theme.dart';
import 'package:repetita/src/features/decks/presentation/deck_list_screen.dart';

class RepetitaApp extends ConsumerWidget {
  const RepetitaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Repetita',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DeckListScreen(),
    );
  }
}
