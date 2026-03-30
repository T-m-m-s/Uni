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
