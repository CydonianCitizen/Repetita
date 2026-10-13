import '../../../core/database/app_database.dart';

/// Seeds a pre-configured sample flashcard deck containing both Basic and Cloze
/// deletion cards to demonstrate study flows, keyboard shortcuts, and FSRS on desktop.
class SampleDeckSeeder {
  const SampleDeckSeeder._();

  static const String sampleDeckName =
      'Mazzo Dimostrativo • FSRS & Spaced Repetition';
  static const String sampleDeckDescription =
      'Mazzo di esempio per testare la visualizzazione su desktop, le scorciatoie di studio e l\'algoritmo FSRS.';

  /// Seeds the sample deck and returns the newly generated deck ID.
  static Future<int> seed(AppDatabase db) async {
    return db.transaction(() async {
      final deckId = await db.decksDao.createDeck(
        name: sampleDeckName,
        description: sampleDeckDescription,
      );

      final now = DateTime.now().toUtc();

      // Card 1: Active Recall (Basic)
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Qual è il principio fondamentale del Richiamo Attivo (Active Recall)?',
        back: 'Il Richiamo Attivo consiste nel compiere lo sforzo cognitivo di recuperare l\'informazione dalla memoria prima di visualizzarne la risposta.\n\nQuesto processo rafforza le connessioni sinaptiche e consolida la memoria a lungo termine in misura nettamente superiore rispetto alla rilettura passiva.',
        now: now,
      );

      // Card 2: FSRS DSR Model (Cloze Deletions c1 and c2)
      const clozeText1 =
          'Nell\'algoritmo FSRS, la {{c1::Stabilità}} misura i giorni necessari affinché la ritraibilità scenda al 90%, mentre la {{c2::Difficoltà}} quantifica la complessità intrinseca del contenuto.';
      const clozeBack1 =
          'Il modello DSR (Difficulty, Stability, Retrievability) di FSRS calcola matematicamente l\'intervallo ottimale prima che la probabilità di ricordo decada oltre la soglia desiderata.';

      await db.cardsDao.createCard(
        deckId: deckId,
        front: clozeText1,
        back: clozeBack1,
        clozeIndex: 1,
        now: now,
      );
      await db.cardsDao.createCard(
        deckId: deckId,
        front: clozeText1,
        back: clozeBack1,
        clozeIndex: 2,
        now: now,
      );

      // Card 3: Desktop Shortcuts (Basic)
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Quali sono le scorciatoie da tastiera per lo studio su Desktop (Windows / macOS)?',
        back: '• Spazio o Invio: Mostra la risposta (Gira la carta)\n• 1: Di nuovo (Again)\n• 2: Difficile (Hard)\n• 3: Buono (Good)\n• 4: Facile (Easy)\n• Ctrl+Z o Cmd+Z: Annulla l\'ultima valutazione (Undo)',
        now: now,
      );

      // Card 4: Ebbinghaus Forgetting Curve (Cloze Deletions c1 and c2)
      const clozeText2 =
          'La curva dell\'oblio scoperta da {{c1::Hermann Ebbinghaus}} dimostra che la ritenzione mnemonica decade in modo {{c2::esponenziale}} nel tempo se l\'informazione non viene richiamata attivamente.';
      const clozeBack2 =
          'A ogni ripasso distanziato al momento opportuno, la curva si appiattisce e il tempo necessario per dimenticare aumenta progressivamente.';

      await db.cardsDao.createCard(
        deckId: deckId,
        front: clozeText2,
        back: clozeBack2,
        clozeIndex: 1,
        now: now,
      );
      await db.cardsDao.createCard(
        deckId: deckId,
        front: clozeText2,
        back: clozeBack2,
        clozeIndex: 2,
        now: now,
      );

      // Card 5: Rating Meanings (Basic)
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Qual è il significato dei quattro pulsanti di valutazione FSRS in Repetita?',
        back: '1. Di nuovo (Again) — Fallimento del ricordo (la carta entra in apprendimento/ripasso immediato)\n2. Difficile (Hard) — Ricordo corretto ma con esitazione o sforzo notevole\n3. Buono (Good) — Ricordo corretto con sforzo standard raccomandato\n4. Facile (Easy) — Ricordo perfetto, istantaneo e privo di qualunque difficoltà',
        now: now,
      );

      // Card 6: Cloze Syntax (Basic)
      await db.cardsDao.createCard(
        deckId: deckId,
        front: 'Come si inserisce una cancellazione cloze (testo nascosto) nell\'editor di Repetita?',
        back: 'Usa la sintassi con doppie parentesi graffe:\n\n{{c1::testo da nascondere}}\n\nPuoi specificare più indici diversi (es. {{c1::...}} e {{c2::...}}) per generare automaticamente carte indipendenti dallo stesso testo o premere il pulsante Cloze nell\'editor.',
        now: now,
      );

      return deckId;
    });
  }
}
