import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a clock function returning current UTC time.
/// Override in tests for deterministic scheduling.
final clockProvider = Provider<DateTime Function()>(
  (ref) => () => DateTime.now().toUtc(),
);
