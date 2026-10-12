# Audit codebase — Repetita

Data: 2026-10-12. Scope: `lib/`, `pubspec.yaml`, repo root. Metodo: `flutter analyze` (pulito, 0 issue) + revisione manuale incrociata agenti (backend/architettura + UI/UX/performance).

Verdetto generale: codice disciplinato (l10n quasi ovunque, `select()` nei watch, `ListView.builder`, transazioni su `recordReview`, niente superficie di path-injection). I problemi veri: versione hardcoded che rompe l'update-check, assenza totale di indici DB, query senza LIMIT, impostazioni utente non persistite, ~400 righe duplicate in settings, gestione SafeArea quasi assente.

---

## 1. Critico / Alta priorità

### 1.1 Versione hardcoded e disallineata — `settings_screen.dart:27`
`appVersion = 'v0.3.0'` mentre `pubspec.yaml` è `0.5.0+0`. La stessa costante alimenta `UpdateCheckController.checkForUpdates` (`update_check_dialog.dart:15`): il confronto di versione usa un valore stantio e può segnalare falsi "aggiornamento disponibile".
**Fix:** leggere la versione da `package_info_plus` (unica fonte di verità).

### 1.2 Nessun indice secondario nel DB — `tables.dart`
`Cards.deckId`, `Cards.due`, `ReviewLogs.cardId`, `ReviewLogs.reviewedAt`, `CardTags.tagId` sono tutti non indicizzati. `watchCardsByDeck`, `fetchDueCards`, join delle statistiche fanno full table scan che peggiorano con la crescita dei dati.
**Fix:** bump `schemaVersion` + migration con `CREATE INDEX`.

### 1.3 Query senza LIMIT
- `study_session_dao.dart:16` `fetchDueCards` e `fetchCustomStudyCards`: caricano l'intero mazzo in memoria a ogni sessione.
- `cards_dao.dart:33` `watchCardsByDeck`: stream dell'intero mazzo senza paginazione (esiste un'API paginata... morta, vedi §3).
**Fix:** cap giornaliero configurabile per la coda studio; paginazione sulla lista carte.

### 1.4 Statistiche calcolate in Dart invece che in SQL — `stats_dao.dart`
- `:51` `getRetentionRate`: carica TUTTI i review log in memoria e conta in Dart.
- `:89` `getDueForecast`: fetch intera tabella `cards` + ciclo annidato giorni × carte (O(7·N)).
**Fix:** `count()` con filtro `rating >= 2`; `GROUP BY date(due)` con `WHERE due < :from+7d`.

### 1.5 Impostazioni non persistite
`theme_mode_controller.dart:9`, `locale_controller.dart:10`, `haptic_controller.dart:10`, `animation_level_controller.dart:10`: ritornano default hardcoded, niente load/save DB. Tema, lingua, aptica, livello animazioni si resettano a ogni avvio — benché la tabella `AppSettings` esista e sia usata per FSRS e reminder.
**Fix:** persistere via `appSettings` come `FsrsParametersController`.

### 1.6 Race FSRS all'avvio a freddo
`fsrs_parameters_controller.dart:15` chiama `_loadFromDb()` non awaited in `build()`; `study_session_controller.dart:171/345` può leggere i parametri di default prima del caricamento e pianificare ripassi con retention/intervalli sbagliati.
**Fix:** provider FSRS async (`FutureOr<FsrsParameters>`) e `await` nel build della sessione.

### 1.7 Rebuild eccessivi lato UI
- `deck_detail_screen.dart:71–105`: l'intero subtree `data:` si ricostruisce a ogni cambio carta/tag; aggregazione tag e scan `dueCount` ricalcolati a ogni emissione.
- `deck_detail_screen.dart:560–568`: filtro in memoria `cards.where(...).toList()` in `build`, O(n) per rebuild, jank con 5k+ carte.
- `study_screen.dart:152–154`: il `Consumer` radice osserva l'intero `studySessionControllerProvider`; ogni voto ricostruisce progress bar, flip card e rating bar.
**Fix:** provider family memoizzati, filtro spostato nel DAO/controller, split in `Consumer` con `select` (pattern già usato solo nell'AppBar).

### 1.8 Animazione flip che flickera — `flip_card_view.dart:36–72`
`TweenAnimationBuilder` avvolge l'intera card (inclusi `SingleChildScrollView` e `Text.rich` con parsing cloze) → ogni frame ricostruisce tutto il volto. L'`.animate(key: ValueKey(card.id))` esterno ri-esegue fade+slide a ogni cambio carta. Inoltre `ClozeParser` è chiamato 4–6 volte per build per faccia (`:153–191`), regex ri-parsate a ogni frame di animazione.
**Fix:** estrarre i volti in widget separati costruiti una volta; cache dei segmenti cloze in `didUpdateWidget`; `AnimationController` in `State`.

### 1.9 Safe-area quasi assente
Un solo `SafeArea` in tutto il progetto (`study_screen.dart:258`). FAB e liste in deck list, settings, backup, stats, card editor possono finire sotto nav bar/cutout; `card_editor_screen.dart:341` ListView senza padding bottom, ultimo campo nascosto dalla barra di sistema.
**Fix:** `SafeArea` sugli Scaffold o padding da `MediaQuery.viewInsetsOf`.

### 1.10 Salvataggio multi-cloze seriale — `card_editor_screen.dart:257–278`
Loop di `await createCard(...)` sequenziali nel layer UI: lo spinner di salvataggio dura N round-trip DB.
**Fix:** metodo unico `createClozeCards()` in transazione nel controller/DAO.

---

## 2. Media priorità

| # | File:linea | Problema | Fix |
|---|---|---|---|
| 2.1 | `backup_service.dart:138` | Merge mode: carte con deckId non nel payload attaccate a mazzi esistenti con stesso id numerico; re-import dello stesso file duplica tutto (niente idempotenza) | Rifiutare/rilocare ref ignote; upsert per identità stabile |
| 2.2 | `backup_service.dart:96,105,246` | Encode/decode JSON e CSV dell'intero DB sull'isolate principale; niente cap di dimensione su payload incollato | `compute()`/isolate + bound input |
| 2.3 | `backup_service.dart:122–215,298–302` | Import riga per riga in loop (anche in transazione unica): secondi per backup grandi | `db.batch(...)` |
| 2.4 | `notification_service.dart:44,77,116,152,160` | Catch silenziosi con solo `debugPrint`; `setEnabled` persiste `enabled=true` anche se lo scheduling fallisce | Rethrow o risultato tipizzato |
| 2.5 | `deck_list_screen.dart:136–149`, `deck_detail_screen.dart:730–750` | Mutazioni async fire-and-forget: errore Drift = eccezione non gestita, nessun feedback | await + SnackBar errore |
| 2.6 | `backup_screen.dart:290–297,304` | Restore distruttivo senza dialog di conferma; `replaceExisting` default `true` (switch pre-armato) | Default `false` + conferma esplicita |
| 2.7 | `settings_screen.dart:102–886` | Build di ~780 righe; due blocchi slider quasi identici (animazione 187–444 vs aptica 448–725) duplicati 1:1 (~400 righe) | Estrarre `_LevelSliderSetting` riusabile |
| 2.8 | `deck_detail_screen.dart:700–708` | `findChildIndexCallback` fa `indexWhere` O(n) per key → O(n²) scroll | Mappa id→indice precomputata |
| 2.9 | `fsrs_parameters_controller.dart:45,57,66–67` | `db.setSetting(...)` unawaited: fallimenti di scrittura silenziosi, stato dice "salvato" | await o `catchError` con log |
| 2.10 | `deck_detail_screen.dart:84–85,259,312,741` | `DateTime.now().toUtc()` nei builder: ricalcolo per tile, niente refresh al cambio giorno | `nowProvider` o calcolo nel controller |
| 2.11 | Animazioni incoerenti | `study_screen.dart:187` shimmer infinito che ignora `animationLevelControllerProvider` (che `rating_bar.dart:24` rispetta) | Gating uniforme di tutti gli `.animate()` |
| 2.12 | Error view copiata 3× | `deck_list_screen.dart:22–55`, `deck_detail_screen.dart:34–70`, `stats_screen.dart:43–79`; `study_screen.dart:158` ha invece solo `Text('$error')` senza retry | Widget condiviso `ErrorView` |
| 2.13 | Touch target < 48dp | `rating_bar.dart:84` (40dp in compact), `settings_screen.dart:419–424,697–704` (bottoni ~34px) | Minimo 48dp, ridurre padding invece |
| 2.14 | Contrasto | `colorScheme.outline` usato come colore testo in più punti (settings 136/356, study 285, etichette heatmap 9sp) | `onSurfaceVariant` |

---

## 3. Codice morto confermato (verificato su tutti i call site)

| Simbolo | Posizione | Nota |
|---|---|---|
| `CardsDao.getCardsByDeckPaged` | `cards_dao.dart:59` | Nessun chiamante. Ironia: è l'unica API paginata e non è usata (vedi §1.3) |
| `CardsDao.getCardsByDeck` | `cards_dao.dart:46` | Chiamato solo dal metodo morto sopra |
| `AppDatabase.watchSetting` | `app_database.dart:65` | Zero call site |
| `TagsDao.deleteTag` + `TagsController.deleteTag` | `tags_dao.dart:38`, `tags_controller.dart:24` | Funzionalità di cancellazione tag irraggiungibile dalla UI |
| `StudySessionController.getIntervalPreviews()` | `study_session_controller.dart:324` | Fallback in `study_screen.dart:372-374` mai attivato: `intervalPreviews` è sempre popolato quando serve |
| `CardsDao.buryCard` (pubblico) | `cards_dao.dart:115` | Usato solo internamente → rendere privato |
| `coverage/lcov.info` | root, tracciato in git | Stantio (ott 10, pre-release 0.5.0), copre frazione minima di `lib` | Cancellare + gitignore |

Concurrency sicura: nessun file `.g.dart` duplicato; generati drift coerenti.

---

## 4. Bassa priorità

- **i18n leak** (~10 stringhe inglesi hardcoded): `deck_detail_screen.dart:394,615,647,682,47`; `backup_screen.dart:282,290–297,395`; `fsrs_settings_dialog.dart:165`; `update_check_dialog.dart:101,117`; plurali hardcoded in `review_heatmap_widget.dart:107`. Fix: chiavi arb.
- **God-object**: settings (993 LOC), deck_detail (758 LOC), card_editor (483 LOC). `_insertCloze` (`card_editor_screen.dart:79–87`) è logica di dominio nel widget → spostare in `ClozeParser` con test.
- **Validazione**: front/back senza cap di lunghezza né validazione sintassi cloze; CSV importer senza limiti righe/dimensione.
- **`buryCardUntilTomorrow`** (`cards_dao.dart:67`): mezzanotte UTC invece che locale → utenti a ovest di UTC hanno carte seppellite ore extra.
- **`study_session_controller.dart:235`**: aritmetica indici coda fragile dopo requeue (sicura ora, a un refactor dal RangeError); modalità cram può far crescere la coda senza bound.
- **Dimensioni fisse non adattive**: `flip_card_view.dart:34` (maxWidth 600, minHeight 280), celle heatmap 14px, row tag 38px; landscape non gestito (la colonna studio schiaccia la card). Fix: `LayoutBuilder` con layout side-by-side in landscape.
- **`card_editor_screen.dart:376–435`**: `ValueListenableBuilder` annidati ricostruiscono l'intero campo back a ogni keystroke.
- **`_showAddTagDialog`** (`card_editor_screen.dart:90–236`): Consumer + StatefulBuilder + doppio setState annidati — fragile, estrarre in StatefulWidget.
- **Backup UX solo clipboard**: niente file picker né share (`backup_screen.dart`); `backup_controller.dart:39` rethrow perde lo stack trace (`Error.throwWithStackTrace`).
- **Feedback incoerente**: delete carta e delete mazzo senza SnackBar di conferma/undo (altrove presenti).
- **`IndexedStack`** (`main_navigation_screen.dart:47`): l'`AnimationController` di Settings registra vsync mentre nascosto — trascurabile ma noto.

---

## 5. Cosa è fatto bene (da preservare)

- `recordReview`/`undoReview` in transazione con coupling del review log; create/update carta+tag transazionali.
- `study_screen.dart` usa `provider.select` per slice dell'AppBar; `RepaintBoundary` sulla heatmap.
- Conferma di cancellazione ben fatta in `deck_list_tile.dart:21–50` (modello da replicare nel restore backup).
- Niente superficie di path injection; update service solo HTTPS con timeout, solo metadata GitHub, niente download.
- `dart analyze` pulito; FK pragma attivi.

## 6. Quick wins ordinati per impatto/sforzo

1. Versione da `package_info_plus` (bug visibile, 5 min).
2. Persistenza tema/lingua/aptica/animazioni via `AppSettings` (bug funzionale percepito, piccolo).
3. Default `replaceExisting=false` + conferma restore (rischio dati, piccolo).
4. Indici DB in migration (fondamenta, piccolo).
5. SQL aggregate per retention/forecast (perf crescente, piccolo).
6. Estrazione `_LevelSliderSetting` in settings (−400 righe duplicate).
7. `SafeArea` ovunque + padding FAB (piccolo).
8. Cache segmenti cloze + split flip card (jank percepito in studio).
9. Pulizia codice morto §3 + cancellazione `coverage/` + gitignore.
10. LIMIT study queue + paginazione lista (riusare l'API paginata già esistente).
