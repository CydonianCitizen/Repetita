import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../decks/presentation/deck_list_screen.dart';
import '../../settings/presentation/controllers/haptic_controller.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stats/presentation/stats_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    final hapticIntensity = ref.read(hapticFeedbackControllerProvider);
    if (!hapticIntensity.isOff) {
      HapticFeedback.selectionClick();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: switch (_currentIndex) {
        0 => const DeckListScreen(),
        1 => const StatsScreen(isEmbedded: true),
        2 => const SettingsScreen(isEmbedded: true),
        _ => const DeckListScreen(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            key: const Key('nav_decks'),
            icon: const Icon(Icons.style_outlined),
            selectedIcon: const Icon(Icons.style),
            label: l10n?.navHome ?? 'Decks',
          ),
          NavigationDestination(
            key: const Key('nav_stats'),
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n?.navStats ?? 'Stats',
          ),
          NavigationDestination(
            key: const Key('nav_settings'),
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n?.navSettings ?? 'Settings',
          ),
        ],
      ),
    );
  }
}
