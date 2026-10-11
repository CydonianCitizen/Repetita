import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'repetita'**
  String get appTitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get navHome;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @decksTitle.
  ///
  /// In en, this message translates to:
  /// **'repetita Decks'**
  String get decksTitle;

  /// No description provided for @noDecksYet.
  ///
  /// In en, this message translates to:
  /// **'No decks yet. Tap + to create one.'**
  String get noDecksYet;

  /// No description provided for @createFirstDeckPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create your first deck to begin spaced repetition studying.'**
  String get createFirstDeckPrompt;

  /// No description provided for @createDeck.
  ///
  /// In en, this message translates to:
  /// **'Create Deck'**
  String get createDeck;

  /// No description provided for @newDeck.
  ///
  /// In en, this message translates to:
  /// **'New Deck'**
  String get newDeck;

  /// No description provided for @deckName.
  ///
  /// In en, this message translates to:
  /// **'Deck Name'**
  String get deckName;

  /// No description provided for @deckDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get deckDescription;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backup;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @totalCardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String totalCardsCount(int count);

  /// No description provided for @dueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} due'**
  String dueCount(int count);

  /// No description provided for @deleteDeckConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this deck? All cards and review history will be lost.'**
  String get deleteDeckConfirmation;

  /// No description provided for @cardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cardsTitle;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @cardFront.
  ///
  /// In en, this message translates to:
  /// **'Front (Question / Prompt)'**
  String get cardFront;

  /// No description provided for @cardBack.
  ///
  /// In en, this message translates to:
  /// **'Back (Answer / Explanation)'**
  String get cardBack;

  /// No description provided for @noCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No cards in this deck yet.'**
  String get noCardsYet;

  /// No description provided for @addCardPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add flashcards to start studying with the FSRS spaced repetition engine.'**
  String get addCardPrompt;

  /// No description provided for @deleteCardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card?'**
  String get deleteCardConfirmation;

  /// No description provided for @studySessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Session'**
  String get studySessionTitle;

  /// No description provided for @showAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show Answer'**
  String get showAnswer;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session Complete!'**
  String get sessionComplete;

  /// No description provided for @sessionCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All due cards in this deck have been reviewed for today.'**
  String get sessionCompleteSubtitle;

  /// No description provided for @noDueCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Caught Up!'**
  String get noDueCardsTitle;

  /// No description provided for @noDueCardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There are no cards due for review in this deck right now.'**
  String get noDueCardsSubtitle;

  /// No description provided for @backToDecks.
  ///
  /// In en, this message translates to:
  /// **'Back to Decks'**
  String get backToDecks;

  /// No description provided for @ratingAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get ratingAgain;

  /// No description provided for @ratingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get ratingHard;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get ratingEasy;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Analytics'**
  String get statsTitle;

  /// No description provided for @retentionRate.
  ///
  /// In en, this message translates to:
  /// **'Retention Rate'**
  String get retentionRate;

  /// No description provided for @totalReviews.
  ///
  /// In en, this message translates to:
  /// **'Total Reviews'**
  String get totalReviews;

  /// No description provided for @cardsLearned.
  ///
  /// In en, this message translates to:
  /// **'Cards Learned'**
  String get cardsLearned;

  /// No description provided for @retentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Percentage of successful recall reviews'**
  String get retentionSubtitle;

  /// No description provided for @cardStateDistribution.
  ///
  /// In en, this message translates to:
  /// **'Card State Distribution'**
  String get cardStateDistribution;

  /// No description provided for @stateNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get stateNew;

  /// No description provided for @stateLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get stateLearning;

  /// No description provided for @stateReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stateReview;

  /// No description provided for @stateRelearning.
  ///
  /// In en, this message translates to:
  /// **'Relearning'**
  String get stateRelearning;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Transfer'**
  String get backupTitle;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export JSON Backup'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an offline JSON backup of all your decks, cards, and review histories.'**
  String get exportDescription;

  /// No description provided for @importDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore or merge flashcards from a JSON backup file.'**
  String get importDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Spaced Repetition Engine • {version}'**
  String appSubtitle(String version);

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get sectionAppearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @themeModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System default, Light, or Dark'**
  String get themeModeSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get themeLight;

  /// No description provided for @animationIntensity.
  ///
  /// In en, this message translates to:
  /// **'Animation Intensity'**
  String get animationIntensity;

  /// No description provided for @animationIntensitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Motion level and micro-interactions'**
  String get animationIntensitySubtitle;

  /// No description provided for @animationReduced.
  ///
  /// In en, this message translates to:
  /// **'Reduced'**
  String get animationReduced;

  /// No description provided for @animationReducedDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant transitions, battery-friendly, accessibility-ready'**
  String get animationReducedDesc;

  /// No description provided for @animationStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get animationStandard;

  /// No description provided for @animationStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced Material 3 fluid transitions'**
  String get animationStandardDesc;

  /// No description provided for @animationExpressive.
  ///
  /// In en, this message translates to:
  /// **'Expressive'**
  String get animationExpressive;

  /// No description provided for @animationExpressiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Playful spring physics, bouncy feedback, and lively motion'**
  String get animationExpressiveDesc;

  /// No description provided for @testMotion.
  ///
  /// In en, this message translates to:
  /// **'Test Motion'**
  String get testMotion;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrations on answer ratings and interactions'**
  String get hapticFeedbackSubtitle;

  /// No description provided for @hapticOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get hapticOff;

  /// No description provided for @hapticOffDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibrations disabled'**
  String get hapticOffDesc;

  /// No description provided for @hapticLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get hapticLight;

  /// No description provided for @hapticLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Subtle tactile clicks'**
  String get hapticLightDesc;

  /// No description provided for @hapticMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get hapticMedium;

  /// No description provided for @hapticMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced physical response'**
  String get hapticMediumDesc;

  /// No description provided for @hapticStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get hapticStrong;

  /// No description provided for @hapticStrongDesc.
  ///
  /// In en, this message translates to:
  /// **'Prominent tactile buzz and pulses'**
  String get hapticStrongDesc;

  /// No description provided for @testHaptic.
  ///
  /// In en, this message translates to:
  /// **'Test Haptics'**
  String get testHaptic;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE & LOCALIZATION'**
  String get sectionLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select app interface language'**
  String get languageSubtitle;

  /// No description provided for @systemLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow device system language'**
  String get systemLanguageSubtitle;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current active language'**
  String get currentLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @sectionStudyAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'STUDY & ALGORITHM'**
  String get sectionStudyAlgorithm;

  /// No description provided for @fsrsParameters.
  ///
  /// In en, this message translates to:
  /// **'FSRS Scheduling Parameters'**
  String get fsrsParameters;

  /// No description provided for @fsrsParametersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Desired retention, max intervals, request weights'**
  String get fsrsParametersSubtitle;

  /// No description provided for @retentionTarget.
  ///
  /// In en, this message translates to:
  /// **'90% retention'**
  String get retentionTarget;

  /// No description provided for @desiredRetention.
  ///
  /// In en, this message translates to:
  /// **'Desired Retention'**
  String get desiredRetention;

  /// No description provided for @desiredRetentionDesc.
  ///
  /// In en, this message translates to:
  /// **'Target recall probability at review time. Higher retention requires more frequent reviews.'**
  String get desiredRetentionDesc;

  /// No description provided for @maxInterval.
  ///
  /// In en, this message translates to:
  /// **'Maximum Interval'**
  String get maxInterval;

  /// No description provided for @maxIntervalDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum spacing interval between reviews in days.'**
  String get maxIntervalDesc;

  /// No description provided for @resetFsrsDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetFsrsDefaults;

  /// No description provided for @fsrsWeights.
  ///
  /// In en, this message translates to:
  /// **'FSRS Model Weights'**
  String get fsrsWeights;

  /// No description provided for @studyReminders.
  ///
  /// In en, this message translates to:
  /// **'Study Reminders'**
  String get studyReminders;

  /// No description provided for @studyRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily review notifications'**
  String get studyRemindersSubtitle;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remindersOff;

  /// No description provided for @enableReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily Study Reminders'**
  String get enableReminders;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get testNotification;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to review with repetita!'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'You have spaced repetition flashcards due for review today.'**
  String get notificationBody;

  /// No description provided for @notificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification dispatched!'**
  String get notificationSent;

  /// No description provided for @reminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive a gentle reminder each day to keep your review streak active and retain flashcards.'**
  String get reminderDesc;

  /// No description provided for @sectionDataBackup.
  ///
  /// In en, this message translates to:
  /// **'DATA & BACKUP'**
  String get sectionDataBackup;

  /// No description provided for @backupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export and import decks via JSON or CSV'**
  String get backupSubtitle;

  /// No description provided for @sectionUpdates.
  ///
  /// In en, this message translates to:
  /// **'UPDATES & RELEASES'**
  String get sectionUpdates;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify installed version against GitHub releases'**
  String get checkForUpdatesSubtitle;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking GitHub releases...'**
  String get checkingForUpdates;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to Date'**
  String get upToDate;

  /// No description provided for @upToDateDesc.
  ///
  /// In en, this message translates to:
  /// **'repetita is currently running the latest version: {version}.'**
  String upToDateDesc(String version);

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available!'**
  String get updateAvailable;

  /// No description provided for @updateAvailableDesc.
  ///
  /// In en, this message translates to:
  /// **'A new version of repetita ({version}) is available.'**
  String updateAvailableDesc(String version);

  /// No description provided for @viewOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGitHub;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates'**
  String get updateCheckFailed;

  /// No description provided for @updateCheckFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get updateCheckFailedDesc;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT & PRIVACY'**
  String get sectionAbout;

  /// No description provided for @licenseAndCredits.
  ///
  /// In en, this message translates to:
  /// **'License & Credits'**
  String get licenseAndCredits;

  /// No description provided for @licenseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MIT License • Open Source'**
  String get licenseSubtitle;

  /// No description provided for @licenseDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'MIT License'**
  String get licenseDialogTitle;

  /// No description provided for @licenseCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright (c) 2026 repetita'**
  String get licenseCopyright;

  /// No description provided for @viewAllLicenses.
  ///
  /// In en, this message translates to:
  /// **'View All Open Source Licenses'**
  String get viewAllLicenses;

  /// No description provided for @comingSoonNotice.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature coming in an upcoming release!'**
  String comingSoonNotice(String feature);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @startStudySession.
  ///
  /// In en, this message translates to:
  /// **'Start Study Session'**
  String get startStudySession;

  /// No description provided for @newCard.
  ///
  /// In en, this message translates to:
  /// **'New Card'**
  String get newCard;

  /// No description provided for @frontPromptCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Front prompt cannot be empty'**
  String get frontPromptCannotBeEmpty;

  /// No description provided for @backAnswerCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Back answer cannot be empty'**
  String get backAnswerCannotBeEmpty;

  /// No description provided for @promptHint.
  ///
  /// In en, this message translates to:
  /// **'Enter question or prompt...'**
  String get promptHint;

  /// No description provided for @answerHint.
  ///
  /// In en, this message translates to:
  /// **'Enter answer...'**
  String get answerHint;

  /// No description provided for @reviewForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'7-Day Review Forecast'**
  String get reviewForecastTitle;

  /// No description provided for @noUpcomingReviews.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reviews scheduled.'**
  String get noUpcomingReviews;

  /// No description provided for @cardStateBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Card State Breakdown'**
  String get cardStateBreakdown;

  /// No description provided for @recallAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Recall accuracy'**
  String get recallAccuracy;

  /// No description provided for @reviewsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total completed'**
  String get reviewsCompleted;

  /// No description provided for @fullDatabaseBackup.
  ///
  /// In en, this message translates to:
  /// **'Full Database Backup (JSON)'**
  String get fullDatabaseBackup;

  /// No description provided for @flashcardsInterchange.
  ///
  /// In en, this message translates to:
  /// **'Flashcards Interchange (CSV)'**
  String get flashcardsInterchange;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @restoreJson.
  ///
  /// In en, this message translates to:
  /// **'Restore JSON'**
  String get restoreJson;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @retention.
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get retention;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @undoReview.
  ///
  /// In en, this message translates to:
  /// **'Undo Review'**
  String get undoReview;

  /// No description provided for @cardUndone.
  ///
  /// In en, this message translates to:
  /// **'Review undone'**
  String get cardUndone;

  /// No description provided for @suspendCard.
  ///
  /// In en, this message translates to:
  /// **'Suspend Card'**
  String get suspendCard;

  /// No description provided for @unsuspendCard.
  ///
  /// In en, this message translates to:
  /// **'Unsuspend Card'**
  String get unsuspendCard;

  /// No description provided for @buryCard.
  ///
  /// In en, this message translates to:
  /// **'Bury Card'**
  String get buryCard;

  /// No description provided for @unburyCard.
  ///
  /// In en, this message translates to:
  /// **'Unbury Card'**
  String get unburyCard;

  /// No description provided for @cardSuspended.
  ///
  /// In en, this message translates to:
  /// **'Card suspended'**
  String get cardSuspended;

  /// No description provided for @cardUnsuspended.
  ///
  /// In en, this message translates to:
  /// **'Card unsuspended'**
  String get cardUnsuspended;

  /// No description provided for @cardBuried.
  ///
  /// In en, this message translates to:
  /// **'Card buried until tomorrow'**
  String get cardBuried;

  /// No description provided for @suspendedBadge.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspendedBadge;

  /// No description provided for @buriedBadge.
  ///
  /// In en, this message translates to:
  /// **'Buried'**
  String get buriedBadge;

  /// No description provided for @reviewHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Review Heatmap'**
  String get reviewHeatmap;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @daysStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysStreak(int count);

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews recorded yet'**
  String get noReviewsYet;

  /// No description provided for @deleteDeckConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Deck?'**
  String get deleteDeckConfirmTitle;

  /// No description provided for @deleteDeckConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? All cards in this deck will be deleted.'**
  String deleteDeckConfirmMessage(String name);

  /// No description provided for @dueBadge.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueBadge;

  /// No description provided for @totalBadge.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalBadge;

  /// No description provided for @promptBadge.
  ///
  /// In en, this message translates to:
  /// **'PROMPT'**
  String get promptBadge;

  /// No description provided for @answerBadge.
  ///
  /// In en, this message translates to:
  /// **'ANSWER'**
  String get answerBadge;

  /// No description provided for @tapToFlipHint.
  ///
  /// In en, this message translates to:
  /// **'Tap or press Show Answer to flip'**
  String get tapToFlipHint;

  /// No description provided for @saveAndAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Save & Add Another'**
  String get saveAndAddAnother;

  /// No description provided for @cardSaved.
  ///
  /// In en, this message translates to:
  /// **'Card saved'**
  String get cardSaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
