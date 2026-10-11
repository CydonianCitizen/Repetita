import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/algorithms/fsrs/models/rating.dart';
import 'package:repetita/src/features/settings/data/haptic_service.dart';
import 'package:repetita/src/features/settings/domain/haptic_intensity.dart';
import 'package:repetita/src/features/settings/presentation/controllers/haptic_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticIntensity enum', () {
    test('fromLevel maps integers correctly', () {
      expect(HapticIntensity.fromLevel(0), HapticIntensity.off);
      expect(HapticIntensity.fromLevel(1), HapticIntensity.light);
      expect(HapticIntensity.fromLevel(2), HapticIntensity.medium);
      expect(HapticIntensity.fromLevel(3), HapticIntensity.strong);
      expect(HapticIntensity.fromLevel(99), HapticIntensity.strong);
    });

    test('isOff property behaves correctly', () {
      expect(HapticIntensity.off.isOff, isTrue);
      expect(HapticIntensity.light.isOff, isFalse);
      expect(HapticIntensity.medium.isOff, isFalse);
      expect(HapticIntensity.strong.isOff, isFalse);
    });
  });

  group('HapticFeedbackController', () {
    test('initializes with medium intensity', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(hapticFeedbackControllerProvider),
        HapticIntensity.medium,
      );
    });

    test('setIntensity updates state reactively', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(
        hapticFeedbackControllerProvider.notifier,
      );

      controller.setIntensity(HapticIntensity.off);
      expect(
        container.read(hapticFeedbackControllerProvider),
        HapticIntensity.off,
      );

      controller.setIntensity(HapticIntensity.strong);
      expect(
        container.read(hapticFeedbackControllerProvider),
        HapticIntensity.strong,
      );
    });
  });

  group('HapticService', () {
    final List<String> hapticCalls = [];

    setUp(() {
      hapticCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'HapticFeedback.vibrate') {
              hapticCalls.add(methodCall.arguments as String? ?? 'vibrate');
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('off intensity does not trigger any haptic calls', () async {
      const service = HapticService();

      await service.triggerRatingFeedback(Rating.again, HapticIntensity.off);
      await service.triggerRatingFeedback(Rating.good, HapticIntensity.off);
      await service.triggerTest(HapticIntensity.off);
      await service.triggerSelection(HapticIntensity.off);

      expect(hapticCalls, isEmpty);
    });

    test(
      'triggers distinct rating patterns for light, medium, strong',
      () async {
        const service = HapticService();

        // Again with strong intensity (double pulse)
        await service.triggerRatingFeedback(
          Rating.again,
          HapticIntensity.strong,
        );
        expect(hapticCalls, contains('HapticFeedbackType.heavyImpact'));
        hapticCalls.clear();

        // Hard with medium intensity
        await service.triggerRatingFeedback(
          Rating.hard,
          HapticIntensity.medium,
        );
        expect(hapticCalls, contains('HapticFeedbackType.mediumImpact'));
        hapticCalls.clear();

        // Good with light intensity
        await service.triggerRatingFeedback(Rating.good, HapticIntensity.light);
        expect(hapticCalls, contains('HapticFeedbackType.selectionClick'));
        hapticCalls.clear();

        // Easy with strong intensity
        await service.triggerRatingFeedback(
          Rating.easy,
          HapticIntensity.strong,
        );
        expect(hapticCalls.length, greaterThanOrEqualTo(1));
        hapticCalls.clear();
      },
    );

    test('triggerTest invokes correct vibration for each intensity', () async {
      const service = HapticService();

      await service.triggerTest(HapticIntensity.light);
      expect(hapticCalls, ['HapticFeedbackType.lightImpact']);
      hapticCalls.clear();

      await service.triggerTest(HapticIntensity.medium);
      expect(hapticCalls, ['HapticFeedbackType.mediumImpact']);
      hapticCalls.clear();

      await service.triggerTest(HapticIntensity.strong);
      expect(hapticCalls, ['HapticFeedbackType.heavyImpact']);
      hapticCalls.clear();
    });

    test('triggerSelection triggers selectionClick', () async {
      const service = HapticService();

      await service.triggerSelection(HapticIntensity.medium);
      expect(hapticCalls, ['HapticFeedbackType.selectionClick']);
    });
  });
}
