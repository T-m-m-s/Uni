-- Tentativo di frode
INSERT INTO Operazioni (tipo, ammontare, numeroConto, idInterfaccia, passwordBancomat) 
VALUES ('Prelievo', 50.00, 2, 1, '1111');

-- Saldo Conto Insufficiente
INSERT INTO Operazioni (tipo, ammontare, numeroConto, idInterfaccia, passwordBancomat) 
VALUES ('Prelievo', 200.00, 2, 2, '2222');

-- Limite Giornaliero Carta
INSERT INTO Operazioni (tipo, ammontare, numeroConto, idInterfaccia, passwordBancomat) 
VALUES ('Prelievo', 600.00, 1, 1, '1111');

-- Prelievo Valido + Aggiornamenti AFTER
INSERT INTO Operazioni (tipo, ammontare, numeroConto, idInterfaccia, passwordBancomat) 
VALUES ('Prelievo', 400.00, 1, 1, '1111');

-- Disponibilità Sportello Insufficiente
-- Dopo il test precedente l'ATM ha solo 600€ rimasti. Alzo il limite giornaliero a 2000, poi provo a prelevare 800€.
UPDATE CartaBancomat SET limiteSpesaGiornaliera = 2000 WHERE passwordBancomat = '1111';
-- RISULTATO ATTESO: ERRORE ("saldo insufficiente sull'Interfaccia 1")
INSERT INTO Operazioni (tipo, ammontare, numeroConto, idInterfaccia, passwordBancomat) 
VALUES ('Prelievo', 800.00, 1, 1, '1111');

-- Deposito Valido
INSERT INTO Operazioni (tipo, ammontare, numeroConto, idInterfaccia, passwordBancomat) 
VALUES ('Deposito', 300.00, 1, 1, '1111');