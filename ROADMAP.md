# Roadmap Sviluppo Repetita (v0.2.0 -> v1.0.0 & Future)

Documento di pianificazione tecnica basato sulle scelte funzionali definite per Repetita (architettura offline-first, motore matematico FSRS, Drift SQLite, Material 3).

---

## Panoramica Versioni

| Versione | Focus Principale | Funzionalità Chiave | Complessità |
| :--- | :--- | :--- | :--- |
| **v0.2.0** <br>*(Completato)* | Core Study Flow & Visual Analytics | • Undo Review (1-step) [x]<br>• Sospensione & Rinvio (Suspend/Bury) [x]<br>• Heatmap Calendario & Streak [x] | Media |
| **v0.2.1** <br>*(Completato)* | Audit, Polish & Consolidamento | • Ponytail dead code cuts & dep purge [x]<br>• Drift due count fix & Backup consistency [x]<br>• Impeccable i18n & batch card creation UX [x] | Bassa |
| **v0.3.0** | Formati Carte & Organizzazione | • Cloze Deletion (`{{c1::...}}`)<br>• Sistema Tag & Filtri per Carta | Media |
| **v0.4.0** | Flessibilità Studio & Ecosistema | • Custom Study (Cram Mode / Ripasso Libero)<br>• Importazione Anki Package (`.apkg`) | Alta |
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

### 3. v0.4.0: Flessibilità Studio & Ecosistema

#### 3.1 Custom Study (Cram Mode / Ripasso Libero)
* **Obiettivo**: Consentire sessioni di studio straordinario prima di un esame, anche quando il conteggio "due" è zero.
* **Specifiche**:
  * Opzioni avvio: "Ripassa tutte le carte", "Ripassa solo carte con Tag X", "Ripassa in anticipo di N giorni".
  * Modalità non distruttiva: possibilità di studiare senza registrare penalità FSRS, oppure registrare anticipi secondo la corretta equazione FSRS per intervalli anticipati.

#### 3.2 Importazione Anki Package (`.apkg`)
* **Obiettivo**: Permettere l'importazione diretta di mazzi dalla vasta libreria della community Anki.
* **Specifiche**:
  * Formato `.apkg`: archivio zip contenente un database SQLite (`collection.anki2` o `collection.anki21`).
  * Decompressione offline tramite package standard `archive`.
  * Parser SQLite per estrarre modelli di note (Basic, Cloze), campi front/back e importare nel database Drift di Repetita.
  * Validazione riga per riga senza crash in caso di formati non riconosciuti.

---

### 4. Funzionalità Differite (Post v1.0.0 / v1.5.0)

Le seguenti feature sono escluse dal percorso critico verso la v1.0.0 e pianificate per la v1.5.0:

* **Ricerca Globale Flashcard (Global Card Browser)**:
  * Schermata dedicata per cercare e filtrare istantaneamente tra migliaia di carte di tutti i mazzi contemporaneamente.
  * Verrà implementata quando la complessità e la mole di carte degli utenti giustificherà una vista browser stile Anki con FTS (Full-Text Search SQLite).
* **Supporto Markdown Avanzato**:
  * Formattazione complessa con tabelle, blocchi di codice con syntax highlighting e formule matematiche LaTeX avanzate.
