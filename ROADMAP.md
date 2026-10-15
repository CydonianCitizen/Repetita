# Roadmap Sviluppo Repetita (v0.2.0 -> v1.0.0 & Future)

Documento di pianificazione tecnica basato sulle scelte funzionali definite per Repetita (architettura offline-first, motore matematico FSRS, Drift SQLite, Material 3).

---

## Panoramica Versioni

| Versione | Focus Principale | Funzionalità Chiave | Complessità |
| :--- | :--- | :--- | :--- |
| **v0.2.0** <br>*(Completato)* | Core Study Flow & Visual Analytics | • Undo Review (1-step) [x]<br>• Sospensione & Rinvio (Suspend/Bury) [x]<br>• Heatmap Calendario & Streak [x] | Media |
| **v0.2.1** <br>*(Completato)* | Audit, Polish & Consolidamento | • Ponytail dead code cuts & dep purge [x]<br>• Drift due count fix & Backup consistency [x]<br>• Impeccable i18n & batch card creation UX [x] | Bassa |
| **v0.3.0** <br>*(Completato)* | Formati Carte & Organizzazione | • Cloze Deletion (`{{c1::...}}`) [x]<br>• Sistema Tag & Filtri per Carta [x] | Media |
| **v0.4.0** <br>*(Completato)* | Flessibilità Studio | • Custom Study (Cram Mode / Ripasso Libero) [x] | Media |
| **v0.6.0** <br>*(Completato)* | Ecosistema & File Transfer | • Importazione Anki Package (`.apkg`) [x]<br>• File Picker & Save nativo (.apkg, .json, .csv) [x]<br>• Ricerca Flashcard per Mazzo [x] | Alta |
| **v0.7.0** <br>*(Completato)* | Desktop Edition (Windows & macOS) | • Supporto nativo desktop Windows (x64) & macOS [x]<br>• Layout adattivo Material 3 (`NavigationRail` vs `NavigationBar`) [x]<br>• Scorciatoie da tastiera (Space, 1-4, Ctrl+Z, Ctrl+Enter) [x]<br>• Dimensioni minime finestra e vincoli ergonomici maxWidth [x] | Media |
| **v0.7.5** <br>*(Completato)* | Astrazione Motore SRS & CI/CD Release | • Interfaccia universale `SrsScheduler` & Riverpod provider [x]<br>• Seeder onboarding mazzo iniziale (`SampleDeckSeeder`) [x]<br>• Fix release pipeline CI/CD (macOS Universal, Windows x64, Android split) [x]<br>• Audit Ponytail & Impeccable (deduplicazione coda studio e dead code) [x] | Bassa |
| **v0.8.0** <br>*(Completato)* | Motore Multi-Algoritmo (FSRS & SM-2) | • Architettura Strategy Pattern per scheduler SRS [x]<br>• Motore logico SM-2 puro (Easiness Factor & Intervalli) [x]<br>• Selettore algoritmo nelle Impostazioni [x]<br>• Migrazione schema Drift e gestione transizioni carte [x] | Media |
| **v0.8.7** <br>*(Completato)* | Performance, Display & Settings Modularization | • Tema Pure Black AMOLED & gestione dinamica refresh rate [x]<br>• PRAGMA SQLite ad alte prestazioni (WAL, cache, mmap) [x]<br>• Haptic feedback nativo Android & ripristino vibrazione [x]<br>• Riorganizzazione modulare impostazioni in sotto-schermate [x] | Media |
| **v1.0.0** | Consolidamento & Stabilità Finale | • Migrazioni Drift blindate<br>• Zero bug, zero warning, 100% test coverage | Bassa |
| **v1.5.0+** | Feature Complesse Deferred | • Ricerca Globale Flashcard (Card Browser)<br>• Markdown avanzato & formattazione ricca | Media |

---

## Dettaglio Funzionalità Scelte

### 1. v0.2.0: Core Study Flow & Visual Analytics [COMPLETATO]

#### 1.1 Undo Review (Limitato a 1 step) [COMPLETATO]
* **Obiettivo**: Permettere di correggere un tap errato sulla barra delle valutazioni senza complicare lo stato.
* **Specifiche**:
  * Limitato esclusivamente all'**ultima carta valutata** nella sessione di studio corrente (buffer di cronologia a dimensione 1).
  * Ripristina in memoria e a database lo stato FSRS precedente della carta (`state`, `stability`, `difficulty`, `due`, `last_review`, `reps`, `lapses`).
  * Elimina l'ultimo record `ReviewLog` generato per quella carta.
  * Pulsante azione "Annulla" visibile nell'AppBar di `StudyScreen` con icona undo e tooltip.
* **Architettura**:
  * Metodo dedicato in `StudySessionDao.undoReview(...)` eseguito in transazione SQLite atomica.
  * Invocazione da `StudySessionController.undoReview()`.

#### 1.2 Sospensione & Rinvio Carte (Suspend / Bury) [COMPLETATO]
* **Obiettivo**: Dare all'utente pieno controllo sulle carte problematiche o già note per la giornata.
* **Specifiche**:
  * **Sospendi (Suspend)**: Disattiva la carta indefinitamente fino a riattivazione manuale. Esclusa da tutte le code di studio.
  * **Rinvia (Bury)**: Rimanda la carta al giorno successivo senza considerarla un fallimento (`Again`).
* **Persistenza (Drift)**:
  * Aggiunta campi alla tabella `Cards`: `isSuspended` (bool, default `false`) e `buriedUntil` (DateTime nullable), schemaVersion 2 con migrazione `onUpgrade`.
  * Aggiornamento query di selezione carte dovute (`getDueCards`) per filtrare `isSuspended == false` e `buriedUntil <= now`.
* **UI**:
  * Badge visuali "Sospesa" e "Rinviata" in `_CardTile`.
  * Voci nel menu popup di `_CardTile` (Sospendi/Riattiva, Rinvia/Annulla rinvio).
  * Voci nel menu popup dell'AppBar di `StudyScreen` (Rinvia carta, Sospendi carta).

#### 1.3 Heatmap Calendario (Attività & Streak) [COMPLETATO]
* **Obiettivo**: Visualizzare la costanza quotidiana e motivare la retention dello studio.
* **Specifiche**:
  * Widget `ReviewHeatmapWidget` (matrice 15 settimane x 7 giorni) integrata in `StatsScreen`.
  * Conteggio recensioni giornaliere aggregato da `ReviewLogs` via `StatsDao.getDailyReviewCounts`.
  * Calcolo dello streak corrente (giorni consecutivi di studio) tramite funzione pura deterministica `calculateStreak`.
  * Badge streak con icona fiamma e gradiente tonale Material 3 proporzionale al volume di studio.
* **Vincoli**:
  * Zero dipendenze esterne: rendering puro Material 3 con tooltip interattivi e legenda.

---

### 2. v0.3.0: Formati Carte & Organizzazione [COMPLETATO]

#### 2.1 Cloze Deletion (Testo a Scomparsa / Riempimento) [COMPLETATO]
* **Obiettivo**: Supportare flashcard con parti di frase nascoste, standard per lingue, definizioni e formule.
* **Specifiche**:
  * Sintassi standard: `{{c1::risposta}}` e con suggerimento opzionale: `{{c1::risposta::suggerimento}}`.
  * Parser puro in Dart (`lib/src/core/algorithms/cloze/`) con zero dipendenze da Flutter o DB.
  * Fronte carta: mostra `[...]` o `[suggerimento]`.
  * Retro carta: mostra la risposta evidenziata nel colore primario del tema M3.
  * Supporto per cloze multipli (`c1`, `c2`) che generano carte indipendenti o mostrano contesti unificati.

#### 2.2 Sistema Tag / Etichette [COMPLETATO]
* **Obiettivo**: Organizzazione trasversale delle carte, indipendente dalla gerarchia dei mazzi.
* **Specifiche**:
  * Tabelle Drift: `Tags` (id, name, color) e tabella ponte `CardTags` (cardId, tagId) con cascading delete.
  * Chip input rapido in `CardEditorScreen`.
  * Badge tag visibili nelle card preview.
  * Filtro rapido per tag nell'elenco carte di un mazzo.

---

### 3. v0.4.0: Flessibilità Studio [COMPLETATO]

#### 3.1 Custom Study (Cram Mode / Ripasso Libero) [COMPLETATO]
* **Obiettivo**: Consentire sessioni di studio straordinario prima di un esame, anche quando il conteggio "due" è zero.
* **Specifiche**:
  * Opzioni avvio: "Ripassa tutte le carte", "Ripassa solo carte con Tag X", "Ripassa in anticipo di N giorni".
  * Modalità non distruttiva: possibilità di studiare senza registrare penalità FSRS, oppure registrare anticipi secondo la corretta equazione FSRS per intervalli anticipati.

---

### 4. v0.6.0: Ecosistema & File Transfer [COMPLETATO]

#### 4.1 Importazione Anki Package (`.apkg`) [COMPLETATO]
* **Obiettivo**: Permettere l'importazione diretta di mazzi dalla vasta libreria della community Anki.
* **Specifiche**:
  * Formato `.apkg`: archivio zip decompresso offline tramite package standard `archive`.
  * Estrazione SQLite `collection.anki2` con package `sqlite3`.
  * Sanitizzazione HTML e conversione markdown con parsing Cloze (`{{c1::...}}`), formattazione e liste pulite.
  * Mappatura modelli Basic, Cloze e Reverse con gestione tag e opzioni di destinazione (nuovo mazzo o mazzo esistente).
  * Inserimento transazionale batch e report statistico (`AnkiImportResult`).

#### 4.2 File Picker & Saver Nativo [COMPLETATO]
* **Obiettivo**: Importazione ed esportazione file direttamente da filesystem/storage senza dipendere unicamente da copia/incolla negli appunti.
* **Specifiche**:
  * Integrazione con `file_picker` incapsulata in `FilePickerService`.
  * Supporto selezione ed esportazione per file `.apkg`, `.json` e `.csv`.

#### 4.3 Ricerca Flashcard per Mazzo [COMPLETATO]
* **Obiettivo**: Trovare rapidamente flashcard per testo (fronte o retro) all'interno di un mazzo.
* **Specifiche**:
  * Barra di ricerca integrata nell'AppBar di `DeckDetailScreen`.
  * Filtraggio combinato dinamico con tag selezionati tramite `filteredDeckCardsProvider`.

---

### 5. v0.7.0: Desktop Edition (Windows & macOS) [COMPLETATO]

#### 5.1 Runner Nativi & Toolchain Multipiattaforma [COMPLETATO]
* **Obiettivo**: Esecuzione e compilazione deterministica offline su Windows (Win32/x64) e macOS (Apple Silicon / Intel).
* **Specifiche**:
  * Scaffolding completo `windows/` e `macos/` generato ed integrato in `analysis_options.yaml`.
  * Generazione asset icone desktop (.ico per Windows, asset catalog per macOS) da `repetita-circle-icon-1024.png`.
  * Introduzione `atl_shim` (`windows/atl_shim/atlbase.h`) per abilitare compilazione C++ MSVC istantanea senza dipendere dal componente opzionale ATL nei Build Tools di Visual Studio.
  * Persistenza database SQLite e archiviazione locale su directory documenti di sistema (`path_provider`).

#### 5.2 Layout Adattivo Material 3 [COMPLETATO]
* **Obiettivo**: Esperienza visiva di primo livello adatta alle proporzioni di monitor widescreen (FHD, QHD, 4K).
* **Specifiche**:
  * `NavigationRail` laterale attivo automaticamente quando la larghezza della finestra è >= 640px.
  * `NavigationBar` inferiore preservata per viewport compatti e schermi verticali.
  * Contenitori con vincoli `BoxConstraints(maxWidth: 800)` e centratura automatica in `StudyScreen` e `CardEditorScreen`.
  * Dimensioni minime della finestra fissate nativamente a 640x500px (`WM_GETMINMAXINFO` su Windows, `NSWindow.minSize` su macOS) per impedire clipping dell'interfaccia.

#### 5.3 Ergonomia Desktop & Scorciatoie da Tastiera [COMPLETATO]
* **Obiettivo**: Velocità di revisione e inserimento rapido paragonabile alle migliori desktop app per ripetizione spaziata (Anki).
* **Specifiche**:
  * **Sessione di Studio**:
    * `Spazio` o `Invio`: Mostra risposta (gira la flashcard).
    * `1`, `2`, `3`, `4`: Seleziona rispettivamente `Again`, `Hard`, `Good`, `Easy`.
    * `Ctrl+Z` / `Cmd+Z`: Annulla l'ultima revisione.
    * Badge visivi con scorciatoia (`1`, `2`, `3`, `4` e `[Space]`) renderizzati sui pulsanti quando in ambiente desktop.
  * **Editor Carte**:
    * `Ctrl+Invio` / `Cmd+Invio` e `Ctrl+S` / `Cmd+S`: Salvataggio immediato della flashcard.

---

### 5.4 v0.7.5: Astrazione Motore SRS & CI/CD Release [COMPLETATO]

#### 5.4.1 Interfaccia SrsScheduler & Decoupling Motore [COMPLETATO]
* **Obiettivo**: Generalizzare il motore di scheduling per preparare l'integrazione di SM-2 senza rompere i contratti esistenti.
* **Specifiche**:
  * Creazione interfaccia pura `SrsScheduler` (`lib/src/core/algorithms/srs/srs_scheduler.dart`).
  * Implementazione di `SrsScheduler` da parte di `FsrsEngine`.
  * Introduzione del provider Riverpod `srsSchedulerProvider` e refactoring di `StudySessionController`.

#### 5.4.2 Mazzo Dimostrativo Onboarding (`SampleDeckSeeder`) [COMPLETATO]
* **Obiettivo**: Fornire mazzo e carte di benvenuto (Basic e Cloze) al primo avvio offline dell'applicazione.
* **Specifiche**:
  * Modulo `SampleDeckSeeder` idempotente attivato se il database non contiene mazzi.
  * Mazzo "Benvenuto su Repetita" con 3 carte didattiche esplicative di FSRS e Cloze Deletion.

#### 5.4.3 Stabilizzazione CI/CD & GitHub Actions Release [COMPLETATO]
* **Obiettivo**: Pipeline di compilazione e rilascio automatica per Android (split APKs), macOS (Universal arm64 + x86_64) e Windows (x64).
* **Specifiche**:
  * Risoluzione conflitto NDK ABI filters in Gradle (`android/app/build.gradle.kts`) per abilitare `--split-per-abi`.
  * Configurazione firma ad-hoc in `Release.xcconfig` e `project.pbxproj` per consentire a Xcode di compilare su GitHub Actions senza account Apple Developer a pagamento.
  * Verifica e packaging via percorso assoluto `$PWD` e `lipo -info` nel workflow di rilascio.

---

### 5.5 v0.8.0: Motore Multi-Algoritmo (FSRS & SM-2) [COMPLETATO]
* **Obiettivo**: Rendere Repetita un benchmark harness agnostico rispetto all'algoritmo SRS, supportando sia il moderno FSRS sia il classico SuperMemo SM-2 con selettore utente.
* **Specifiche**:
  * **Modulo SM-2 Puro** (`lib/src/core/algorithms/sm2/`):
    * Modello matematico a zero dipendenze per calcolo di $EF$ (Easiness Factor), intervalli $I(n)$, e gestione lapse con rating 1..4 (Again, Hard, Good, Easy).
    * Test unitari con 100% di copertura.
  * **SrsScheduler Strategy Pattern**: [COMPLETATO in v0.7.5]
    * Astrazione comune che disaccoppia `StudySessionController` e `StudySessionDao` dal tipo concreto di motore.
  * **Impostazioni & Selezione**:
    * Opzione di selezione motore in `SettingsScreen` (FSRS vs SM-2) salvata in `AppSettings`.
  * **Gestione Transizione & Persistenza**:
    * Migrazione Drift per accogliere i metadati SM-2 senza perdita di coerenza per le carte preesistenti.
    * Miglioramento dell'import Anki (`.apkg`) per preservare il fattore $EF$ originario.

---

### 5.6 v0.8.7: Performance, Display & Settings Modularization [COMPLETATO]
* **Obiettivo**: Minimizzare i consumi energetici su display OLED/AMOLED, massimizzare il throughput I/O del database locale, ripristinare il feedback aptico nativo e razionalizzare la UI delle impostazioni.
* **Specifiche**:
  * **Tema AMOLED Pure Black**:
    * Palette scura a contrasto assoluto (`#000000`) per azzerare l'assorbimento dei pixel su display OLED.
    * Integrato in `AppThemeMode.amoled` con toggle dedicato e persistenza Riverpod.
  * **Ottimizzazione I/O SQLite (`AppDatabase`)**:
    * Configurazione PRAGMA: `journal_mode = WAL`, `synchronous = NORMAL`, `cache_size = -64000` (64MB), `temp_store = MEMORY`, `mmap_size = 268435456` (256MB).
  * **Gestione Dinamica Refresh Rate**:
    * `DisplayRefreshRateService` con platform channel Android (`setPreferredDisplayMode`) per limitare il frame rate (60Hz / Standard / Massimo) durante lo studio e risparmiare batteria.
  * **Feedback Aptico Nativo**:
    * Platform channel nativo Android (`repetita/haptics`) con fallback su `HapticFeedback` di Flutter e permesso `android.permission.VIBRATE` per garantire il funzionamento su tutti i dispositivi.
  * **Modularizzazione Impostazioni**:
    * Scomposizione della schermata Impostazioni in sotto-schermate tematiche: *Aspetto*, *Algoritmo di studio*, *Lingua*, *Aggiornamenti*, *Informazioni*.
    * Rimozione del word wrapping disomogeneo e pulizia dei badge testuali ridondanti nella navigazione principale.

---

### 6. Funzionalità Differite (Post v1.0.0 / v1.5.0)

Le seguenti feature sono escluse dal percorso critico verso la v1.0.0 e pianificate per la v1.5.0:

* **Ricerca Globale Flashcard (Global Card Browser)**:
  * Schermata dedicata per cercare e filtrare istantaneamente tra migliaia di carte di tutti i mazzi contemporaneamente.
  * Verrà implementata quando la complessità e la mole di carte degli utenti giustificherà una vista browser stile Anki con FTS (Full-Text Search SQLite).
* **Supporto Markdown Avanzato**:
  * Formattazione complessa con tabelle, blocchi di codice con syntax highlighting e formule matematiche LaTeX avanzate.
