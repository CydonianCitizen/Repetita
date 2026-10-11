import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

extension CardStateColors on ColorScheme {
  Color cardStateColor(int state) {
    switch (state) {
      case 0:
        return primary;
      case 1:
        return tertiary;
      case 2:
        return secondary;
      case 3:
        return error;
      default:
        return outline;
    }
  }
}

String cardStateName(int state, AppLocalizations? l10n) {
  switch (state) {
    case 0:
      return l10n?.stateNew ?? 'New';
    case 1:
      return l10n?.stateLearning ?? 'Learning';
    case 2:
      return l10n?.stateReview ?? 'Review';
    case 3:
      return l10n?.stateRelearning ?? 'Relearning';
    default:
      return 'Unknown';
  }
}
