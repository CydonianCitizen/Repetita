// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Repetita';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Search';

  @override
  String get decksTitle => 'Repetita Decks';

  @override
  String get noDecksYet => 'No decks yet. Tap + to create one.';

  @override
  String get createFirstDeckPrompt =>
      'Create your first deck to begin spaced repetition studying.';

  @override
  String get createDeck => 'Create Deck';

  @override
  String get newDeck => 'New Deck';

  @override
  String get deckName => 'Deck Name';

  @override
  String get deckDescription => 'Description (optional)';

  @override
  String get study => 'Study';

  @override
  String get cards => 'Cards';

  @override
  String get stats => 'Statistics';

  @override
  String get backup => 'Backup & Restore';

  @override
  String get settings => 'Settings';

  @override
  String totalCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String dueCount(int count) {
    return '$count due';
  }

  @override
  String get deleteDeckConfirmation =>
      'Are you sure you want to delete this deck? All cards and review history will be lost.';

  @override
  String get cardsTitle => 'Cards';

  @override
  String get addCard => 'Add Card';

  @override
  String get editCard => 'Edit Card';

  @override
  String get cardFront => 'Front (Question / Prompt)';

  @override
  String get cardBack => 'Back (Answer / Explanation)';

  @override
  String get noCardsYet => 'No cards in this deck yet.';

  @override
  String get addCardPrompt =>
      'Add flashcards to start studying with the FSRS spaced repetition engine.';

  @override
  String get deleteCardConfirmation =>
      'Are you sure you want to delete this card?';

  @override
  String get studySessionTitle => 'Study Session';

  @override
  String get showAnswer => 'Show Answer';

  @override
  String get sessionComplete => 'Session Complete!';

  @override
  String get sessionCompleteSubtitle =>
      'All due cards in this deck have been reviewed for today.';

  @override
  String get noDueCardsTitle => 'All Caught Up!';

  @override
  String get noDueCardsSubtitle =>
      'There are no cards due for review in this deck right now.';

  @override
  String get backToDecks => 'Back to Decks';

  @override
  String get ratingAgain => 'Again';

  @override
  String get ratingHard => 'Hard';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingEasy => 'Easy';

  @override
  String get statsTitle => 'Review Analytics';

  @override
  String get retentionRate => 'Retention Rate';

  @override
  String get totalReviews => 'Total Reviews';

  @override
  String get cardsLearned => 'Cards Learned';

  @override
  String get retentionSubtitle => 'Percentage of successful recall reviews';

  @override
  String get cardStateDistribution => 'Card State Distribution';

  @override
  String get stateNew => 'New';

  @override
  String get stateLearning => 'Learning';

  @override
  String get stateReview => 'Review';

  @override
  String get stateRelearning => 'Relearning';

  @override
  String get backupTitle => 'Backup & Transfer';

  @override
  String get exportBackup => 'Export JSON Backup';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get exportDescription =>
      'Create an offline JSON backup of all your decks, cards, and review histories.';

  @override
  String get importDescription =>
      'Restore or merge flashcards from a JSON backup file.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String appSubtitle(String version) {
    return 'Offline Spaced Repetition Engine • $version';
  }

  @override
  String get sectionAppearance => 'APPEARANCE';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeModeSubtitle => 'System default, Light, or Dark';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get animationIntensity => 'Animation Intensity';

  @override
  String get animationIntensitySubtitle =>
      'Motion level and micro-interactions';

  @override
  String get animationReduced => 'Reduced';

  @override
  String get animationReducedDesc =>
      'Instant transitions, battery-friendly, accessibility-ready';

  @override
  String get animationStandard => 'Standard';

  @override
  String get animationStandardDesc => 'Balanced Material 3 fluid transitions';

  @override
  String get animationExpressive => 'Expressive';

  @override
  String get animationExpressiveDesc =>
      'Playful spring physics, bouncy feedback, and lively motion';

  @override
  String get testMotion => 'Test Motion';

  @override
  String get sectionLanguage => 'LANGUAGE & LOCALIZATION';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Select app interface language';

  @override
  String get systemLanguageSubtitle => 'Follow device system language';

  @override
  String get currentLanguage => 'Current active language';

  @override
  String get english => 'English';

  @override
  String get italian => 'Italiano';

  @override
  String get spanish => 'Español';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get active => 'Active';

  @override
  String get sectionStudyAlgorithm => 'STUDY & ALGORITHM';

  @override
  String get fsrsParameters => 'FSRS Scheduling Parameters';

  @override
  String get fsrsParametersSubtitle =>
      'Desired retention, max intervals, request weights';

  @override
  String get retentionTarget => '90% retention';

  @override
  String get studyReminders => 'Study Reminders';

  @override
  String get studyRemindersSubtitle => 'Daily review notifications';

  @override
  String get remindersOff => 'Off';

  @override
  String get enableReminders => 'Daily Study Reminders';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get testNotification => 'Send Test Notification';

  @override
  String get notificationTitle => 'Time to review with Repetita!';

  @override
  String get notificationBody =>
      'You have spaced repetition flashcards due for review today.';

  @override
  String get notificationSent => 'Test notification dispatched!';

  @override
  String get reminderDesc =>
      'Receive a gentle reminder each day to keep your review streak active and retain flashcards.';

  @override
  String get sectionUpdates => 'UPDATES & RELEASES';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get checkForUpdatesSubtitle =>
      'Verify installed version against GitHub releases';

  @override
  String get checkingForUpdates => 'Checking GitHub releases...';

  @override
  String get upToDate => 'Up to Date';

  @override
  String upToDateDesc(String version) {
    return 'Repetita is currently running the latest version: $version.';
  }

  @override
  String get updateAvailable => 'Update Available!';

  @override
  String updateAvailableDesc(String version) {
    return 'A new version of Repetita ($version) is available.';
  }

  @override
  String get viewOnGitHub => 'View on GitHub';

  @override
  String get updateCheckFailed => 'Could not check for updates';

  @override
  String get updateCheckFailedDesc =>
      'Please check your internet connection and try again.';

  @override
  String get sectionAbout => 'ABOUT & PRIVACY';

  @override
  String get offlinePrivacy => 'Local & Offline-First';

  @override
  String get offlinePrivacySubtitle =>
      'Zero cloud telemetry, zero remote tracking';

  @override
  String get licenseAndCredits => 'License & Credits';

  @override
  String get licenseSubtitle => 'MIT License • Open Source';

  @override
  String comingSoonNotice(String feature) {
    return '$feature feature coming in an upcoming release!';
  }
}
