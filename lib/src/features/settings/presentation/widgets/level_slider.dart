import 'package:flutter/material.dart';

/// Discrete-step slider with labels, shared by animation and haptic settings.
class LevelSlider extends StatelessWidget {
  const LevelSlider({
    super.key,
    required this.sliderKey,
    required this.value,
    required this.divisions,
    required this.labels,
    required this.activeIndex,
    required this.onChanged,
  });

  final Key sliderKey;
  final double value;
  final int divisions;
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            thumbColor: colorScheme.primary,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 2,
            ),
            overlayColor: colorScheme.primary.withValues(alpha: 0.16),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
            activeTickMarkColor: colorScheme.onPrimary,
            inactiveTickMarkColor: colorScheme.outline,
          ),
          child: Slider(
            key: sliderKey,
            value: value,
            min: 0.0,
            max: divisions.toDouble(),
            divisions: divisions,
            label: labels[value.round().clamp(0, labels.length - 1)],
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < labels.length; i++)
                Text(
                  labels[i],
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: i == activeIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: i == activeIndex
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
