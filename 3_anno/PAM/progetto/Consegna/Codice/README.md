# Crucible - D&D 5e Character Manager

## 1. System Concept Statement
L'applicazione è uno strumento mobile pensato per i giocatori di Dungeons & Dragons 5e, dai neofiti ai veterani, che semplifica radicalmente il processo di creazione e gestione del personaggio. A differenza dei tool digitali concorrenti, spesso sovraccarichi di informazioni e limitati da paywall, l'app offre un'interfaccia utente pulita e guidata che traduce input semplificati in una scheda personaggio completa ed esportabile in formato PDF. L'applicazione si distingue per l'integrazione di API gratuite (Open5e) per l'autocompletamento, e per una 'Custom Mode' flessibile che permette ai giocatori di integrare facilmente regole homebrew. Nel medio termine, l'app supporterà anche il tracking attivo durante la sessione, fungendo da compagno digitale completo.

## 2. Competitive Assessment
L'app si posiziona come un'alternativa UX-first ai principali competitor:

*   **D&D Beyond:** Offre un database immenso ma con paywall restrittivi. **Crucible** usa Open5e per offrire un'alternativa gratuita e accessibile.
*   **Character Keep:** UI curata ma esportazione limitata. **Crucible** mantiene la chiarezza visiva garantendo un output PDF professionale.
*   **DnD Character Sheet:** Esportazione PDF a pagamento e UI datata. **Crucible** offre il PDF come funzionalità core gratuita con design moderno.
*   **The 20:** Interfaccia scarna. **Crucible** implementa la *progressive disclosure* per un inserimento dati fluido e interattivo.

## 3. Requirements Brief

### Priorità ALTA (Essenziali - MVP)
*   **REQ-01 Input Guidato Dati Base:** Inserimento sequenziale di Classe, Razza e Statistiche.
*   **REQ-02 Calcolo Automatico:** Gestione automatica di CA, HP massimi e Slot Incantesimo.
*   **REQ-03 Esportazione/Importazione PDF:** Generazione e lettura di schede standard.
*   **REQ-04 Custom Mode (Homebrew):** Toggle per disabilitare le restrizioni regolistiche.
*   **REQ-05 Autocompletamento API:** Ricerca rapida tramite integrazione Open5e.
*   **REQ-06 Multi-Metodo Caratteristiche:** Supporto per Manuale, Array Standard, Point Buy e Dadi.
*   **REQ-07 Filtro Fonti:** Limitazione del compendio al solo manuale base o espansioni.
*   **REQ-08 Rivelazione Dinamica:** Visualizzazione dei soli privilegi pertinenti al livello attuale.

### Priorità MEDIA (Tracking in Sessione)
*   **REQ-09 Gestione Inventario a due livelli:** Separazione tra zaino ed equipaggiamento indossato.
*   **REQ-10 Tracker Risorse:** Modifica rapida di HP attuali e slot consumati.
*   **REQ-11 Blocco Note:** Area di testo per appunti di sessione.

### Priorità BASSA (Futuro)
*   **REQ-12 Toggle "Neofita/Hardcore":** Interfaccia adattiva basata sull'esperienza.
*   **REQ-13 Gestione Party/Campagna:** Connessione tra personaggi dello stesso gruppo.

---
*Sviluppato con Flutter utilizzando le API di Open5e.*
