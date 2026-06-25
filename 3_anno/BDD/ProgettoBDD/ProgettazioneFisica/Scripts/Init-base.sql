-- 1. BANCHE E FILIALI
INSERT INTO Banca (nomeBanca, commissioneAltri, commissioneConsorzio) VALUES 
('Banca del Popolo', 2.50, 1.00),
('Global Bank', 3.00, 0.50);

INSERT INTO Filiale (indirizzo, codiceBanca) VALUES 
('Via Roma 10, Milano', 1),    -- Codice 1
('Corso Italia 5, Roma', 1),   -- Codice 2
('Piazza Grande 1, Torino', 2);-- Codice 3

-- 2. PERSONE
INSERT INTO Persona (codiceFiscale, nome, indirizzo) VALUES
('MRARSS80A01H501U', 'Mario Rossi', 'Via Garibaldi 1, Milano'),
('LNDBNC85M10L219Z', 'Linda Bianchi', 'Via Mazzini 20, Roma'),
('ANNBAS95A01L219B', 'Anna Bassi', 'Via Veneto 8, Roma'),
('GNNVRD90T15F205W', 'Giovanni Verdi', 'Via Torino 45, Torino'),
('FRNFRR75S12H501A', 'Franco Ferrari', 'Via Dante 12, Milano');

-- 3. CLIENTI E IMPIEGATI
INSERT INTO Cliente (codiceFiscale) VALUES
('MRARSS80A01H501U'), -- Mario
('LNDBNC85M10L219Z'), -- Linda
('ANNBAS95A01L219B'), -- Anna
('GNNVRD90T15F205W'); -- Giovanni (Serve per la Query 8: è sia Impiegato che Cliente)

INSERT INTO Impiegato (dataAssunzione, codiceFiscale) VALUES
('2015-06-01', 'GNNVRD90T15F205W'), -- Id 1 (Giovanni, assunto nel 2015. Verrà licenziato nella Q5)
('2018-03-15', 'FRNFRR75S12H501A'); -- Id 2

-- 4. STORICO SERVIZIO IMPIEGATI
INSERT INTO PrestaServizioIn (idImpiegato, codiceFiliale, dataInizio, dataFine) VALUES 
(1, 1, '2015-06-01', NULL),         -- Giovanni lavora attualmente in Filiale 1 (Servirà per la Q4 di trasferimento)
(2, 2, '2018-03-15', '2022-01-01'), -- Franco ha lavorato in Filiale 2...
(2, 3, '2022-01-02', NULL);         -- ...e ora lavora in Filiale 3.

-- 5. CONTI CORRENTI
INSERT INTO Conto (dataApertura, dataEstinzione, ammontare, codiceFiliale) VALUES 
('2020-01-10', NULL, 50000.00, 1), -- Conto 1: Mario in Filiale 1 (Saldo altissimo per vincere la Q6)
('2021-05-20', NULL, 12500.00, 2), -- Conto 2: Mario in Filiale 2 (Mario ha conti nelle Filiali {1, 2})
('2021-06-10', NULL, 8000.00, 1),  -- Conto 3: Linda in Filiale 1
('2021-07-20', NULL, 4500.00, 2),  -- Conto 4: Linda in Filiale 2 (Linda ha conti nelle Filiali {1, 2} -> MATCH CON MARIO PER LA Q9!)
('2022-11-12', NULL, 3000.00, 3),  -- Conto 5: Anna in Filiale 3 (Solo Filiale {3}, non fa match)
('2019-01-01', NULL, 15000.00, 1); -- Conto 6: Giovanni in Filiale 1 (Aperto nel 2019, > 5 anni. MATCH PER LA Q8!)

-- 6. INTESTATARI DEI CONTI
INSERT INTO IntestatoA (codiceFiscale, numeroConto) VALUES 
('MRARSS80A01H501U', 1),
('MRARSS80A01H501U', 2),
('LNDBNC85M10L219Z', 3),
('LNDBNC85M10L219Z', 4),
('ANNBAS95A01L219B', 5),
('GNNVRD90T15F205W', 6);

-- 7. CARTE BANCOMAT (Limiti alzati per far passare i test)
INSERT INTO CartaBancomat (passwordBancomat, limiteSpesaGiornaliera, limiteSpesaMensile, numeroConto, codiceFiscale) VALUES 
('PASS123', 2000.00, 5000.00, 1, 'MRARSS80A01H501U'),
('PASS456', 1000.00, 5000.00, 3, 'LNDBNC85M10L219Z');
-- 8. INTERFACCE
INSERT INTO Interfaccia (tipo, disponibilita, codiceFiliale, numOperazioni) VALUES 
('Sportello', 10000.00, 1, 2), -- Int 1 (Filiale 1) -> Avrà solo operazioni > 1000 (Test Q7)
('Cassa', 50000.00, 2, 2),     -- Int 2 (Filiale 2) -> Avrà un'operazione < 1000 (Test Q7)
('Sportello', 15000.00, 3, 0); -- Int 3 (Filiale 3) -> Interfaccia su cui eseguirai la tua Q2 di inserimento

-- 9. OPERAZIONI PREGRESSE
INSERT INTO Operazioni (dataOperazione, ora, tipo, ammontare, numeroConto, idInterfaccia, passwordBancomat) VALUES 
-- Operazioni su Interfaccia 1 (Filiale 1): Il prelievo è 1500, ora passerà!
('2026-05-01', '10:30:00', 'Prelievo', 1500.00, 1, 1, 'PASS123'),
('2026-05-02', '11:00:00', 'Deposito', 2500.00, 1, 1, 'PASS123'),

-- Operazioni su Interfaccia 2 (Filiale 2)
('2026-05-03', '14:20:00', 'Deposito', 2000.00, 2, 2, 'PASS123'), 
('2026-05-04', '09:00:00', 'Prelievo', 100.00, 2, 2, 'PASS123');