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
