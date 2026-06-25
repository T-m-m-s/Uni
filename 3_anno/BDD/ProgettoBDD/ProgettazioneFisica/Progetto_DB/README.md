# Sistema Gestionale Consorzio Bancario

Questo progetto implementa il database di un consorzio bancario, gestendo la struttura delle banche, le filiali, i conti correnti, le carte bancomat e le operazioni di sportello/cassa.

## Struttura della Sottodirectory

- `sql/`: Script SQL per la creazione e gestione del database.
  - `00_init_db.sql`: Inizializzazione del database e dello schema.
  - `01_schema.sql`: Definizione delle tabelle (DDL).
  - `02_constraints.sql`: Vincoli di integrità e chiavi esterne.
  - `03_logic.sql`: Funzioni e trigger (Logica di Business).
  - `04_data.sql`: Caricamento dati di test.
  - `05_queries.sql`: Interrogazioni di analisi e reportistica.
- `data/`: Cartella destinata a contenere i file CSV generati per il popolamento.
- `generate_data.py`: Script Python che utilizza la libreria `Faker` per generare migliaia di record coerenti.
- `config.env`: File di configurazione per le credenziali del database (da creare partendo da `config.env.example`).
- `main.sh`: Script di orchestrazione per l'esecuzione dei comandi SQL.

## Funzionalità Principali

### 1. Logica di Business Automatizzata (Trigger e Procedure)
Il sistema integra una logica complessa a livello database per garantire l'integrità e la coerenza dei dati:
- **Validazione Sicurezza Carte**: Ogni operazione verifica che la password della carta sia corretta e che la carta stessa sia associata al conto corrente indicato, prevenendo tentativi di frode.
- **Gestione Risorse Umane**: 
  - Impedisce il trasferimento di un impiegato in una filiale dove ha già prestato servizio in passato.
  - Impone un periodo minimo di permanenza di un mese prima di consentire un nuovo trasferimento.
- **Motore di Prelievo Intelligente**:
  - Verifica in tempo reale la disponibilità del saldo (includendo il calcolo delle commissioni).
  - Controlla la giacenza fisica di contante nell'interfaccia utilizzata (ATM o Cassa).
  - Monitora e impone i limiti di spesa giornalieri e mensili configurati per ogni carta.
- **Ciclo di Vita del Conto**: In caso di estinzione di un conto, il sistema azzera automaticamente il saldo e invalida permanentemente tutte le carte e le operazioni associate per motivi di sicurezza e storage.
- **Vincoli Operativi**: Distingue tra diverse tipologie di interfacce (es. le casse fisiche supportano solo depositi e prelievi diretti).

### 2. Sistema di Commissioni Dinamico
Il calcolo delle commissioni è automatizzato e varia in base alla "vicinanza" tra banca emittente e filiale ospitante:
- **Zero Commissioni**: Se il cliente opera presso una filiale della propria banca.
- **Tariffa Consorzio**: Se l'operazione avviene presso una banca appartenente al consorzio ma il cliente non è impiegato dello stesso.
- **Tariffa Extra-Consorzio**: Applicata per operazioni verso istituti esterni.


##  Istruzioni per l'Uso

1. **Generazione Dati** (notare che alcune query effettuate hanno parametri di ricerca hardcoded basati sui dati attualmente generati, ad esempio nella restituzione di informazioni per un'interfaccia):
   ```bash
   pip install faker
   python3 generate_data.py

2. **Run Script** (l'esecuzione dello script richiede che il servizio di PostgreSQL sia attivo, in caso non lo fosse lo script proverà ad eseguire `sudo systemctl start postgresql` per attivarlo):
   ```bash
   ./main.sh
