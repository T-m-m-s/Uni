# Progetto Basi di Dati — Rete Bancaria Informatizzata

## Descrizione del Progetto

Questo progetto riguarda la progettazione di una base di dati per una **rete bancaria informatizzata** costituita da un consorzio di banche che condividono sportelli automatizzati (Bancomat).

L'obiettivo è modellare il sistema per gestire le relazioni tra banche, filiali, dipendenti, clienti, conti correnti e operazioni bancarie, includendo la gestione delle carte Bancomat e i relativi costi di commissione.

---

## Analisi dei Requisiti (Esercizio 3)

Il sistema deve gestire le seguenti entità e vincoli.

### Entità Principali

| Entità          | Identificatore                  | Attributi principali                                         |
|-----------------|---------------------------------|--------------------------------------------------------------|
| Banca           | Codice univoco                  | Nome, commissione consorzio, commissione altro               |
| Filiale         | Codice univoco                  | Indirizzo fisico, casse, sportelli                           |
| Persona         | Codice fiscale univoco          | Nome, indirizzo                                              |
| Impiegato       | Codice univoco                  | Data di assunzione                                           |
| Cliente         | —                               | —                                                            |
| Conto Corrente  | Numero di conto univoco         | Data di apertura, data di estinzione, ammontare              |
| Carta Bancomat  | Password univoca                | Limite mensile, limite giornaliero                           |
| Interfaccia     | Codice univoco                  | Tipo, disponibilità                                          |

### Vincoli

**Interfaccia** — può essere di tipo Sportello o Cassa:

- **Sportello**: effettua solo operazioni di Deposito o Prelievo. Al Prelievo sono attribuite due possibili commissioni:
  - `CommissioneAltri` — per clienti di altre banche
  - `CommissioneConsorzio` — se lo sportello fa parte del consorzio

- **Cassa**: effettua ogni tipo di operazione.

**Operazioni** suddivise in:

- Prelievo
- Deposito
- Saldo
- Lista Movimenti

**Cliente Impiegato**: non ha costi per Prelievi agli Sportelli del Consorzio.

---

## Operazioni

| #  | Descrizione                                                                        | Frequenza stimata  |
|----|------------------------------------------------------------------------------------|--------------------|
| 1  | Informazioni di un'interfaccia (compreso # operazioni effettuate)                  | ~500 / giorno      |
| 2  | Inserimento di un'operazione su un'interfaccia, da conto preesistente              | ~50.000 / giorno   |
| 3  | Assunzione di un impiegato in una data filiale                                     | ~0,5 / giorno      |
| 4  | Trasferimento di un impiegato in una filiale e controllo vincoli temporali         | ~0,1 / giorno      |
| 5  | Licenziamento di un impiegato                                                      | ~0,011 / giorno    |
| 6  | Trovare cliente con ammontare totale bancomat maggiore                             | ~0.033 / giorno    |
| 7  | Trovare interfacce di filiale con operazioni di ammontare < 10000                  | ~0,033 / giorno    |
| 8  | Trovare impiegati che lavorano in una filiale da almeno 5 anni e sono clienti      | ~0,033 / giorno    |
| 9  | Trovare coppie di clienti che hanno cc in esattamente gli stessi insiemi di filiali| ~0,033 / giorno    |

---

## Struttura

```text
.
├── Materiali/                # Traccia del progetto e slide di riferimento
├── ProgettazioneConcettuale/ # Modelli ER (sorgenti .dia ed esportazioni .png)
├── ProgettazioneLogica/      # Progettazione logica, analisi delle prestazioni e navigazione
│   ├── SchemiNavigazione/    # Schemi di navigazione per le operazioni principali
│   └── TavoleOVA.ods         # Tavole Operazioni, Volumi e Accessi
├── Relazione/                # Relazione finale in LaTeX
│   ├── sections/             # Contenuto suddiviso per capitoli (sorgenti .tex)
│   └── main.tex              # File principale per la compilazione
├── README.md
└── .gitignore
```
