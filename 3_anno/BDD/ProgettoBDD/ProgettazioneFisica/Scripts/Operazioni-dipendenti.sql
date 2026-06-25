-- Prima assegnazione in assoluto
INSERT INTO PrestaServizioIn (idImpiegato, codiceFiliale, dataInizio) VALUES (1, 1, '2023-01-01');
INSERT INTO PrestaServizioIn (idImpiegato, codiceFiliale, dataInizio) VALUES (2, 2, '2026-05-01');

-- Trasferimento Negato (Non è passato 1 mese)
INSERT INTO PrestaServizioIn (idImpiegato, codiceFiliale, dataInizio) VALUES (2, 3, '2026-05-08');

-- Trasferimento Negato (Ha già lavorato lì)
INSERT INTO PrestaServizioIn (idImpiegato, codiceFiliale, dataInizio) VALUES (1, 1, '2026-05-08');

-- Trasferimento Valido + Autochiusura
INSERT INTO PrestaServizioIn (idImpiegato, codiceFiliale, dataInizio) VALUES (1, 3, '2026-05-08');

-- Licenziamento e pulizia a cascata
DELETE FROM Impiegato WHERE idImpiegato = 2;