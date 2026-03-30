# Slide 1: Integrazione di Vitest in Neeche

### Architettura e Ruolo Nello Stack
All'interno del moderno ecosistema tecnologico di **Neeche** (*Fastify + TypeScript + Vite*), **Vitest** si inserisce nativamente offrendo un ambiente di testing robusto e quasi istantaneo. Condividendo la medesima *build pipeline* e configurazione di Vite, minimizza l'attrito configurativo elevando la Developer Experience.

L'obiettivo primario del *testing backend* per questa WebApp strutturata in Location Intelligence è l'accurata **validazione della business logic** per la produzione dei dati derivati (come la Saturazione del mercato e il Gap Competitivo).

### Modello Matematico: Opportunity Index
Il motore analitico di Neeche aggrega i dati grezzi per generare metriche di Location decision-making. Garantiamo, per ciascun aggiornamento del software, la solidità applicativa di formule strutturali come la seguente:

$$ Opportunity\ Index = \ln\left(1 + \frac{Demand_{Ads}}{Supply_{Places} + 1}\right) \times (1 - Gap_{Competitivo}) $$

### Il Paradigma del "Mocking"
Perché non interrogare direttamente le API di Google ad ogni test?
1. **Determinismo Scientifico**: I dati reali di volume query (Google Ads API) e business (Places API) fluttuano in real-time, inficiando la componente deterministica e replicabile attesa dai test architetturali.
2. **Isolamento ed Economia**: Le test-suite necessitano di rapidità d'esecuzione senza il burden della latenza di rete e indipendentemente dai Rate Limit. Tramite il **Mocking** (es. `vi.mock()`) iniettiamo nell'ambiente virtuale payload di pre-risposta falsi per le entità esterne, isolando esclusivamente il dominio del calcolo algoritmico della piattaforma.

---

# Slide 2: Automazione CI/CD

### Proteggere la Delivery con la Continuous Integration
L'accuratezza dei dati di mercato in Neeche è essenziale; un errore di refactoring potrebbe corrompere i ranking geografici prodotti per l'utente finale. L'adozione di una pipeline di Continuous Integration (CI) assicura che il codice venga dinamicamente controllato in Cloud prima del rilascio.

Automatizzando del tutto l'ambiente di Vitest al momento di ogni Push o Pull Request, il team di ricerca si assicura di intercettare regressioni silenti senza intervento umano.

### Esempio Pratico: GitHub Actions Automation (`test.yml`)
Ecco l'infrastruttura dichiarativa del workflow da collocare in `.github/workflows/`. Ad ogni commit, una macchina virtuale convalida staticamente l'intero progetto di Backend, per poi superare le Suite di test prima del rilascio.

```yaml
name: Neeche Core CI

on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main" ]

jobs:
  backend-test:
    name: Backend Validation Unit
    runs-on: ubuntu-latest

    steps:
    - name: 📦 Checkout Repository
      uses: actions/checkout@v4
      
    - name: 🟢 Setup Node.js (v20) Environment
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
        
    - name: ⬇️ Install Dependencies
      run: npm ci
      
    - name: 🔎 TypeScript Type-Checking
      run: npx tsc --noEmit
      
    - name: 🧪 Execute Vitest Validation Suite
      run: npm run test:coverage
```

---

# Slide 3.1: Demo Tecnica (Domain Logic)

### Modello di Dominio in TypeScript: `opportunity.ts`
Esposizione del modulo che incapsula la pura business logic. Progettiamo il layer ignorando di proposito i concetti e l'implementazione del networking per i layer inferiori, rendendo molto semplice il Testing Unitario per l'Opportunity Index.

```typescript
export interface LocationMetrics {
  demandAds: number;      // Mese corrente - Volume di ricerche Google Ads
  supplyPlaces: number;   // Entità business nell'area analizzata (Places API)
  competitiveGap: number; // Valore misurato come coefficiente tra [0, 1]
}

export function computeOpportunityIndex(metrics: LocationMetrics): number {
  const { demandAds, supplyPlaces, competitiveGap } = metrics;

  // 1. Validazione statica (Programmazione Difensiva) contro input corrotti da API
  if (demandAds < 0 || supplyPlaces < 0 || competitiveGap < 0 || competitiveGap > 1) {
    throw new Error("Validation Error: bound limits exceeded in external integration data.");
  }

  // 2. Early Return per domanda nulla (nessun potenziale nel mercato)
  if (demandAds === 0) return 0;

  // 3. Modello logaritmico per smussare le code sui macro-volumi
  const demandToSupplyRatio = demandAds / (supplyPlaces + 1);
  const rawIndex = Math.log(1 + demandToSupplyRatio) * (1 - competitiveGap);

  // Normalizzazione a due decimi per l'output in tabella ranking
  return Number(rawIndex.toFixed(2));
}
```

---

# Slide 3.2: Demo Tecnica (Test Suite)

### Validazione della logica: `opportunity.test.ts`
Implementazione del file per Vitest. Analizziamo *Casi Limite* ed eventuali input errati lanciati dalle fasi di Mocking, esigendo risultati esatti e robusta tolleranza alle anomalie del codice (Throw Errors handling).

```typescript
import { describe, it, expect } from 'vitest';
import { computeOpportunityIndex, LocationMetrics } from './opportunity';

describe('Location Intelligence Core: Opportunity Index Generativo', () => {

  it('dovrebbe calcolare un elevato Opportunity Index nei gap ottimali ad alta domanda', () => {
    // Simulazione (Mock implicito) area a bassissima concorrenza ma alta ricerca.
    const targetZone: LocationMetrics = { demandAds: 5000, supplyPlaces: 4, competitiveGap: 0.1 };
    const index = computeOpportunityIndex(targetZone);
    
    // Formula check: ln(1 + 1000) * 0.9 = 6.908 * 0.9 = approx 6.21
    expect(index).toBeGreaterThan(6.0);
    expect(index).toBeLessThan(6.5);
    expect(index).toBe(6.22); // Verifica del toFixed arrotondato
  });

  it('dovrebbe gestire in scioltezza le cold-zones restituendo un flat zero rate', () => {
    const deadZone: LocationMetrics = { demandAds: 0, supplyPlaces: 10, competitiveGap: 0.8 };
    expect(computeOpportunityIndex(deadZone)).toBe(0);
  });

  it('dovrebbe lanciare una Eccezione (User-Defined) per input API anomali o corrotti', () => {
    const anomalyApiZone = { demandAds: -100, supplyPlaces: 5, competitiveGap: 1.5 };
    
    // Vitest intercetta le eccezioni per validare che l'App non processi dati spazzatura
    expect(() => computeOpportunityIndex(anomalyApiZone))
      .toThrowError(/bound limits exceeded/);
  });
});
```
