// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'repetita';

  @override
  String get close => 'Chiudi';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get ok => 'OK';

  @override
  String get search => 'Cerca';

  @override
  String get navHome => 'Mazzi';

  @override
  String get navStats => 'Statistiche';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get decksTitle => 'Mazzi repetita';

  @override
  String get noDecksYet => 'Nessun mazzo presente. Tocca + per crearne uno.';

  @override
  String get createFirstDeckPrompt =>
      'Crea il tuo primo mazzo per iniziare a studiare con la ripetizione spaziata.';

  @override
  String get createDeck => 'Crea mazzo';

  @override
  String get newDeck => 'Nuovo mazzo';

  @override
  String get deckName => 'Nome mazzo';

  @override
  String get deckDescription => 'Descrizione (opzionale)';

  @override
  String get study => 'Studia';

  @override
  String get cards => 'Carte';

  @override
  String get stats => 'Statistiche';

  @override
  String get backup => 'Backup e ripristino';

  @override
  String get settings => 'Impostazioni';

  @override
  String totalCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carte',
      one: '1 carta',
    );
    return '$_temp0';
  }

  @override
  String dueCount(int count) {
    return '$count da ripassare';
  }

  @override
  String get deleteDeckConfirmation =>
      'Sei sicuro di voler eliminare questo mazzo? Tutte le carte e la cronologia delle ripetizioni andranno perse.';

  @override
  String get cardsTitle => 'Carte';

  @override
  String get addCard => 'Aggiungi carta';

  @override
  String get editCard => 'Modifica carta';

  @override
  String get cardFront => 'Fronte (Domanda / Prompt)';

  @override
  String get cardBack => 'Retro (Risposta / Spiegazione)';

  @override
  String get noCardsYet => 'Nessuna carta in questo mazzo.';

  @override
  String get addCardPrompt =>
      'Aggiungi flashcard per iniziare a studiare con il motore a ripetizione spaziata FSRS.';

  @override
  String get deleteCardConfirmation =>
      'Sei sicuro di voler eliminare questa carta?';

  @override
  String get studySessionTitle => 'Sessione di studio';

  @override
  String get showAnswer => 'Mostra risposta';

  @override
  String get sessionComplete => 'Sessione completata!';

  @override
  String get sessionCompleteSubtitle =>
      'Tutte le carte in scadenza per oggi in questo mazzo sono state ripassate.';

  @override
  String get noDueCardsTitle => 'Tutto in pari!';

  @override
  String get noDueCardsSubtitle =>
      'Non ci sono carte da ripassare in questo mazzo in questo momento.';

  @override
  String get backToDecks => 'Torna ai mazzi';

  @override
  String get ratingAgain => 'Ripeti';

  @override
  String get ratingHard => 'Difficile';

  @override
  String get ratingGood => 'Buono';

  @override
  String get ratingEasy => 'Facile';

  @override
  String get statsTitle => 'Analisi ripassi';

  @override
  String get retentionRate => 'Tasso di ritenzione';

  @override
  String get totalReviews => 'Revisioni totali';

  @override
  String get cardsLearned => 'Carte apprese';

  @override
  String get retentionSubtitle => 'Percentuale di risposte corrette';

  @override
  String get cardStateDistribution => 'Distribuzione stati carte';

  @override
  String get stateNew => 'Nuova';

  @override
  String get stateLearning => 'Apprendimento';

  @override
  String get stateReview => 'Ripasso';

  @override
  String get stateRelearning => 'Riapprendimento';

  @override
  String get backupTitle => 'Backup e trasferimento';

  @override
  String get exportBackup => 'Esporta backup JSON';

  @override
  String get importBackup => 'Importa backup';

  @override
  String get exportDescription =>
      'Crea un backup JSON offline di tutti i tuoi mazzi, carte e cronologia.';

  @override
  String get importDescription =>
      'Ripristina o unisci flashcard da un file di backup JSON.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String appSubtitle(String version) {
    return 'Motore a ripetizione spaziata offline • $version';
  }

  @override
  String get sectionAppearance => 'ASPETTO';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeModeSubtitle => 'Predefinito di sistema, Chiaro o Scuro';

  @override
  String get themeSystem => 'Predefinito di sistema';

  @override
  String get themeDark => 'Tema Scuro';

  @override
  String get themeLight => 'Tema Chiaro';

  @override
  String get animationIntensity => 'Intensità animazioni';

  @override
  String get animationIntensitySubtitle =>
      'Livello di movimento e micro-interazioni';

  @override
  String get animationReduced => 'Ridotte';

  @override
  String get animationReducedDesc =>
      'Transizioni istantanee, risparmio energetico e massima accessibilità';

  @override
  String get animationStandard => 'Standard';

  @override
  String get animationStandardDesc =>
      'Transizioni fluide bilanciate Material 3';

  @override
  String get animationExpressive => 'Espressive';

  @override
  String get animationExpressiveDesc =>
      'Fisica elastica dinamica, micro-interazioni ricche ed espressive';

  @override
  String get testMotion => 'Prova movimento';

  @override
  String get hapticFeedback => 'Feedback aptico';

  @override
  String get hapticFeedbackSubtitle => 'Vibrazioni alla risposta e interazioni';

  @override
  String get hapticOff => 'Disattivato';

  @override
  String get hapticOffDesc => 'Vibrazioni disattivate';

  @override
  String get hapticLight => 'Leggero';

  @override
  String get hapticLightDesc => 'Click tattili delicati';

  @override
  String get hapticMedium => 'Medio';

  @override
  String get hapticMediumDesc => 'Risposta fisica bilanciata';

  @override
  String get hapticStrong => 'Forte';

  @override
  String get hapticStrongDesc => 'Vibrazioni decise e impulsi tattili';

  @override
  String get testHaptic => 'Prova vibrazione';

  @override
  String get sectionLanguage => 'LINGUA E LOCALIZZAZIONE';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get language => 'Lingua';

  @override
  String get languageSubtitle => 'Seleziona la lingua dell\'interfaccia';

  @override
  String get systemLanguageSubtitle => 'Segui la lingua del dispositivo';

  @override
  String get currentLanguage => 'Lingua attualmente attiva';

  @override
  String get english => 'English';

  @override
  String get italian => 'Italiano';

  @override
  String get spanish => 'Español';

  @override
  String get comingSoon => 'Prossimamente';

  @override
  String get active => 'Attiva';

  @override
  String get sectionStudyAlgorithm => 'STUDIO E ALGORITMO';

  @override
  String get fsrsParameters => 'Parametri algoritmo FSRS';

  @override
  String get fsrsParametersSubtitle =>
      'Ritenzione desiderata, intervalli massimi, pesi';

  @override
  String get retentionTarget => '90% ritenzione';

  @override
  String get desiredRetention => 'Ritenzione desiderata';

  @override
  String get desiredRetentionDesc =>
      'Probabilità di ricordo stimata al ripasso. Una ritenzione più alta richiede ripassi più frequenti.';

  @override
  String get maxInterval => 'Intervallo massimo';

  @override
  String get maxIntervalDesc =>
      'Intervallo massimo di ripasso espresso in giorni.';

  @override
  String get resetFsrsDefaults => 'Ripristina predefiniti';

  @override
  String get fsrsWeights => 'Pesi del modello FSRS';

  @override
  String get studyReminders => 'Promemoria di studio';

  @override
  String get studyRemindersSubtitle => 'Notifiche giornaliere di ripasso';

  @override
  String get remindersOff => 'Disattivate';

  @override
  String get enableReminders => 'Promemoria giornaliero di studio';

  @override
  String get reminderTime => 'Orario promemoria';

  @override
  String get testNotification => 'Invia notifica di prova';

  @override
  String get notificationTitle => 'È ora di ripassare con repetita!';

  @override
  String get notificationBody =>
      'Hai delle flashcard in scadenza da ripassare oggi.';

  @override
  String get notificationSent => 'Notifica di prova inviata!';

  @override
  String get reminderDesc =>
      'Ricevi un promemoria ogni giorno all\'orario stabilito per mantenere costante la tua memoria.';

  @override
  String get sectionDataBackup => 'DATI E BACKUP';

  @override
  String get backupSubtitle => 'Esporta e importa mazzi tramite JSON o CSV';

  @override
  String get sectionUpdates => 'AGGIORNAMENTI E RELEASE';

  @override
  String get checkForUpdates => 'Verifica aggiornamenti';

  @override
  String get checkForUpdatesSubtitle =>
      'Confronta la versione installata con le release GitHub';

  @override
  String get checkingForUpdates => 'Verifica release su GitHub in corso...';

  @override
  String get upToDate => 'Aggiornato';

  @override
  String upToDateDesc(String version) {
    return 'repetita è attualmente aggiornata all\'ultima versione: $version.';
  }

  @override
  String get updateAvailable => 'Nuovo aggiornamento disponibile!';

  @override
  String updateAvailableDesc(String version) {
    return 'Una nuova versione di repetita ($version) è disponibile su GitHub.';
  }

  @override
  String get viewOnGitHub => 'Vedi su GitHub';

  @override
  String get updateCheckFailed => 'Impossibile verificare gli aggiornamenti';

  @override
  String get updateCheckFailedDesc =>
      'Verifica la tua connessione internet e riprova.';

  @override
  String get sectionAbout => 'INFO E PRIVACY';

  @override
  String get licenseAndCredits => 'Licenza e riconoscimenti';

  @override
  String get licenseSubtitle => 'Licenza MIT • Open Source';

  @override
  String get licenseDialogTitle => 'Licenza MIT';

  @override
  String get licenseCopyright => 'Copyright (c) 2026 repetita';

  @override
  String get viewAllLicenses => 'Tutte le licenze open source';

  @override
  String comingSoonNotice(String feature) {
    return 'Funzionalità $feature disponibile in un prossimo aggiornamento!';
  }

  @override
  String get retry => 'Riprova';

  @override
  String get startStudySession => 'Inizia sessione di studio';

  @override
  String get newCard => 'Nuova carta';

  @override
  String get frontPromptCannotBeEmpty => 'La domanda non può essere vuota';

  @override
  String get backAnswerCannotBeEmpty => 'La risposta non può essere vuota';

  @override
  String get promptHint => 'Inserisci domanda o prompt...';

  @override
  String get answerHint => 'Inserisci risposta...';

  @override
  String get reviewForecastTitle => 'Previsione ripassi a 7 giorni';

  @override
  String get noUpcomingReviews => 'Nessun ripasso programmato.';

  @override
  String get cardStateBreakdown => 'Distribuzione stati carte';

  @override
  String get recallAccuracy => 'Precisione di rievocazione';

  @override
  String get reviewsCompleted => 'Totale completate';

  @override
  String get fullDatabaseBackup => 'Backup completo database (JSON)';

  @override
  String get flashcardsInterchange => 'Interscambio flashcard (CSV)';

  @override
  String get exportJson => 'Esporta JSON';

  @override
  String get restoreJson => 'Ripristina JSON';

  @override
  String get exportCsv => 'Esporta CSV';

  @override
  String get importCsv => 'Importa CSV';

  @override
  String get copyToClipboard => 'Copia negli appunti';

  @override
  String get retention => 'Ritenzione';

  @override
  String get reviews => 'Ripassi';

  @override
  String get undo => 'Annulla';

  @override
  String get undoReview => 'Annulla ripasso';

  @override
  String get cardUndone => 'Ripasso annullato';

  @override
  String get suspendCard => 'Sospendi carta';

  @override
  String get unsuspendCard => 'Riattiva carta';

  @override
  String get buryCard => 'Rinvia carta';

  @override
  String get unburyCard => 'Annulla rinvio';

  @override
  String get cardSuspended => 'Carta sospesa';

  @override
  String get cardUnsuspended => 'Carta riattivata';

  @override
  String get cardBuried => 'Carta rinviata a domani';

  @override
  String get suspendedBadge => 'Sospesa';

  @override
  String get buriedBadge => 'Rinviata';

  @override
  String get reviewHeatmap => 'Mappa delle revisioni';

  @override
  String get streak => 'Serie';

  @override
  String get currentStreak => 'Serie attuale';

  @override
  String daysStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get noReviewsYet => 'Nessuna revisione registrata';

  @override
  String get deleteDeckConfirmTitle => 'Eliminare il mazzo?';

  @override
  String deleteDeckConfirmMessage(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"? Tutte le carte in questo mazzo verranno eliminate.';
  }

  @override
  String get dueBadge => 'Da ripassare';

  @override
  String get totalBadge => 'Totale';

  @override
  String get promptBadge => 'DOMANDA';

  @override
  String get answerBadge => 'RISPOSTA';

  @override
  String get tapToFlipHint => 'Tocca o premi Mostra risposta per girare';

  @override
  String get saveAndAddAnother => 'Salva e aggiungi un\'altra';

  @override
  String get cardSaved => 'Carta salvata';
}
