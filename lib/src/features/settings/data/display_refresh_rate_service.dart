import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../domain/refresh_rate_preference.dart';

class DisplayRefreshRateService {
  const DisplayRefreshRateService();

  static const MethodChannel _channel = MethodChannel(
    'com.example.repetita/display_mode',
  );

  Future<bool> setRefreshRate(RefreshRatePreference preference) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final success = await _channel.invokeMethod<bool>(
        'setPreferredRefreshRate',
        {'fps': preference.targetFps},
      );
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('DisplayRefreshRateService failed to set rate: $e');
      return false;
    }
  }

  Future<double> getCurrentRefreshRate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      try {
        final views = WidgetsBinding.instance.platformDispatcher.views;
        if (views.isNotEmpty) {
          return views.first.display.refreshRate;
        }
      } catch (_) {}
      return 60.0;
    }
    try {
      final rate = await _channel.invokeMethod<double>('getCurrentRefreshRate');
      return rate ?? 60.0;
    } on PlatformException catch (e) {
      debugPrint('DisplayRefreshRateService failed to get rate: $e');
      return 60.0;
    }
  }
}
