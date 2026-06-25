-- PULIZIA DB

do $$ 
	declare
		r RECORD;
	begin
		for r in (select tablename from pg_tables where schemaname = 'public') loop
			execute 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
		end loop;
	end $$;

-- CREAZIONE TABELLE

CREATE TABLE Banca (
    codiceBanca integer generated always as identity PRIMARY KEY,
    nomeBanca TEXT,
    commissioneAltri NUMERIC(15,2),
    commissioneConsorzio NUMERIC(15,2)
);

create table Filiale (
    codiceFiliale integer generated always as identity primary key,
    indirizzo TEXT,
    codiceBanca integer,
foreign key (codiceBanca) references Banca(codiceBanca)
);

CREATE TABLE Persona (
    codiceFiscale TEXT PRIMARY KEY,
    nome TEXT,
    indirizzo TEXT
);

CREATE TABLE Cliente (
    codiceFiscale TEXT PRIMARY KEY,
    FOREIGN KEY (codiceFiscale) REFERENCES Persona(codiceFiscale)
);

CREATE TABLE Impiegato (
    idImpiegato integer generated always as identity UNIQUE,
    dataAssunzione DATE,
    codiceFiscale TEXT PRIMARY KEY,
    FOREIGN KEY (codiceFiscale) REFERENCES Persona(codiceFiscale)
);

create table Conto (
    numeroConto integer generated always as identity primary key,
    dataApertura DATE,
    dataEstinzione DATE,
    ammontare numeric(15, 2),
    codiceFiliale integer,
    foreign key (codiceFiliale) references Filiale(codiceFiliale)
);

CREATE TABLE IntestatoA (
    codiceFiscale TEXT,
    numeroConto integer,
    PRIMARY KEY (codiceFiscale, numeroConto),
    FOREIGN KEY (codiceFiscale) REFERENCES Cliente(codiceFiscale),
    FOREIGN KEY (numeroConto) REFERENCES Conto(numeroConto)
);

CREATE TABLE PrestaServizioIn (
    idImpiegato integer,
    codiceFiliale integer,
    dataInizio DATE NOT NULL,
    dataFine DATE,
    PRIMARY KEY (idImpiegato, codiceFiliale, dataInizio),
    FOREIGN KEY (idImpiegato) REFERENCES Impiegato(idImpiegato),
    FOREIGN KEY (codiceFiliale) REFERENCES Filiale(codiceFiliale),
    CHECK (dataFine IS NULL OR dataFine >= dataInizio)
);

CREATE TABLE CartaBancomat (
    passwordBancomat TEXT PRIMARY KEY,
    limiteSpesaGiornaliera NUMERIC(15,2),
    limiteSpesaMensile NUMERIC(15,2),
    spesaGiornaliera NUMERIC(15,2) DEFAULT 0,
    spesaMensile NUMERIC(15,2) DEFAULT 0,
    numeroConto integer,
    codiceFiscale TEXT,
    FOREIGN KEY (numeroConto) REFERENCES Conto(numeroConto),
    FOREIGN KEY (codiceFiscale) REFERENCES Cliente(codiceFiscale)
);

CREATE TABLE Interfaccia (
    idInterfaccia integer generated always as identity PRIMARY KEY,
    tipo TEXT CHECK(tipo IN ('Sportello', 'Cassa')),
    disponibilita NUMERIC(15,2),
    codiceFiliale integer,
    numOperazioni integer DEFAULT 0,
    FOREIGN KEY (codiceFiliale) REFERENCES Filiale(codiceFiliale)
);

CREATE TABLE Operazioni (
    idOperazione integer generated always as identity PRIMARY KEY,
    dataOperazione DATE DEFAULT CURRENT_DATE,
    ora TIME DEFAULT CURRENT_TIME,
    tipo TEXT CHECK(tipo IN ('Prelievo', 'Deposito', 'Saldo', 'Lista Movimenti')),
    ammontare NUMERIC(15,2),
    numeroConto integer,
    idInterfaccia integer,
    passwordBancomat TEXT NOT NULL,
    FOREIGN KEY (numeroConto) REFERENCES Conto(numeroConto),
    FOREIGN KEY (idInterfaccia) REFERENCES Interfaccia(idInterfaccia),
    FOREIGN KEY (passwordBancomat) REFERENCES CartaBancomat(passwordBancomat)
);

-- CREAZIONE TRIGGER

create or replace function check_prelievo()
returns trigger as $$
declare
	ammontare_attuale NUMERIC(15,2);
	disponibilita_attuale NUMERIC(15,2);
begin
	if new.tipo = 'Prelievo' then
		select ammontare into ammontare_attuale
		from conto
		where numeroConto = new.numeroConto;

		if new.ammontare > ammontare_attuale then
			raise exception 'Operazione Negata: saldo insufficiente sul conto %.', new.numeroConto;
		end if;
	
		select disponibilita into disponibilita_attuale
		from interfaccia
		where idInterfaccia = new.idInterfaccia;

		if new.ammontare > disponibilita_attuale then
			raise exception 'Operazione Negata: saldo insufficiente sull''Interfaccia %', new.idInterfaccia;
		end if;
	end if;

	return new;
end;
$$ language plpgsql;

create trigger trg_blocco_prelievo
before insert on Operazioni
for each row
execute function check_prelievo();

create or replace function update_counter_operazioni()
returns trigger as $$
begin
	update interfaccia
	set numOperazioni = numOperazioni + 1
	where idInterfaccia = new.idInterfaccia;

	return new;
end;
$$ language plpgsql;

create trigger trg_update_numOp
after insert on Operazioni
for each row
execute function update_counter_operazioni();

create or replace function remove_employment()
returns trigger as $$
begin
	delete from PrestaServizioIn
	where idImpiegato = old.idImpiegato;
	return old;
end;
$$ language plpgsql;

create trigger trg_licenziamento_impiegato
before delete on Impiegato
for each row
execute function remove_employment();

create or replace function check_trasferimento_insert()
returns trigger as $$
begin
	if exists (
		select 1 from PrestaServizioIn
		where idImpiegato = new.idImpiegato AND
			  codiceFiliale = new.codiceFiliale
		) then raise exception 'Trasferimento Negato: l''impiegato % ha già prestato servizio nella filiale %.', new.idImpiegato, new.codiceFiliale;
	end if;

	if not exists (
		select 1 from PrestaServizioIn	
		where idImpiegato = new.idImpiegato AND
			  datafine is null AND
			  datainizio <= CURRENT_DATE - INTERVAL '1 month'
		) then raise exception 'Trasferimento Negato: l''impiegato % non lavora nella filiale corrente da più di un mese.', new.idImpiegato;
	end if;

	return new;
end;
$$ language plpgsql;

create trigger trg_check_trasferimento_insert
before insert on PrestaServizioIn
for each row
execute function check_trasferimento_insert();

-- POPOLAMENTO DB

INSERT INTO Banca (nomeBanca, commissioneAltri, commissioneConsorzio) VALUES 
('Banca del Popolo', 2.50, 1.00),
('Global Bank', 3.00, 0.50);

INSERT INTO Filiale (indirizzo, codiceBanca) VALUES 
('Via Roma 10, Milano', 1),
('Corso Italia 5, Roma', 1),
('Piazza Grande 1, Torino', 2);

INSERT INTO Persona (codiceFiscale, nome, indirizzo) VALUES
('MRARSS80A01H501U', 'Mario Rossi', 'Via Garibaldi 1, Milano'),
('LNDBNC85M10L219Z', 'Linda Bianchi', 'Via Mazzini 20, Roma'),
('GNNVRD90T15F205W', 'Giovanni Verdi', 'Via Torino 45, Torino'),
('FRNFRR75S12H501A', 'Franco Ferrari', 'Via Dante 12, Milano'),
('ANNBAS95A01L219B', 'Anna Bassi', 'Via Veneto 8, Roma');

INSERT INTO Cliente (codiceFiscale) VALUES
('MRARSS80A01H501U'),
('LNDBNC85M10L219Z'),
('ANNBAS95A01L219B');

INSERT INTO Impiegato (dataAssunzione, codiceFiscale) VALUES
('2015-06-01', 'GNNVRD90T15F205W'),
('2018-03-15', 'FRNFRR75S12H501A');

INSERT INTO PrestaServizioIn (idImpiegato, codiceFiliale, dataInizio, dataFine) VALUES 
(1, 3, '2015-06-01', NULL),
(2, 1, '2018-03-15', '2022-01-01'),
(2, 2, '2022-01-02', NULL);

INSERT INTO Conto (dataApertura, dataEstinzione, ammontare, codiceFiliale) VALUES 
('2020-01-10', NULL, 5000.00, 1),
('2021-05-20', NULL, 12500.00, 2),
('2019-11-12', '2023-12-31', 0.00, 3);

INSERT INTO IntestatoA (codiceFiscale, numeroConto) VALUES 
('MRARSS80A01H501U', 1),
('LNDBNC85M10L219Z', 2),
('ANNBAS95A01L219B', 2);

INSERT INTO CartaBancomat (passwordBancomat, limiteSpesaGiornaliera, limiteSpesaMensile, numeroConto, codiceFiscale) VALUES 
('PASS123', 500.00, 3000.00, 1, 'MRARSS80A01H501U'),
('PASS456', 1000.00, 5000.00, 2, 'LNDBNC85M10L219Z');

INSERT INTO Interfaccia (tipo, disponibilita, codiceFiliale, numOperazioni) VALUES 
('Sportello', 10000.00, 1, 150),
('Sportello', 8000.00, 2, 45),
('Sportello', 15000.00, 3, 0),
('Cassa', 50000.00, 1, 10);

INSERT INTO Operazioni (dataOperazione, ora, tipo, ammontare, numeroConto, idInterfaccia, passwordBancomat) VALUES 
('2026-05-01', '10:30:00', 'Prelievo', 100.00, 1, 1, 'PASS123'),
('2026-05-02', '14:20:00', 'Deposito', 2000.00, 2, 3, 'PASS456');

-- QUERY 1: Restituisce informazioni su una data interfaccia (ex. 1)

select * 
from interfaccia as i
where i.idInterfaccia = 1;

-- QUERY 2: Inserimento di una operazione (di prelievo 50) da un conto (1) con bancomat (PASS123) s una interfaccia (1)

with commissione as (
	select B.commissioneConsorzio
	from Interfaccia i
	join Filiale f on i.codiceFiliale = f.codiceFiliale
	join Banca b on f.codiceBanca = b.codiceBanca
	where i.idInterfaccia = 3
)
insert into Operazioni (dataOperazione, ora, tipo, ammontare, numeroConto, idInterfaccia, passwordBancomat)
select CURRENT_DATE, CURRENT_TIME, 'Prelievo', 50.00 + commissioneConsorzio, 1, 3, 'PASS123'
from commissione;

select * from operazioni;

-- QUERY 3: Assunzione di un nuovo impiegato in una filiale

with new_user as (
	insert into Persona (codiceFiscale, nome, indirizzo) values 
	('BNCMRR92L10H501T', 'Bianca Rossi', 'Via delle Scienze 208, Udine')
	on conflict (codiceFiscale) do update
		set codiceFiscale = EXCLUDED.codiceFiscale
	returning codiceFiscale
),
new_employee as (
	insert into Impiegato (dataAssunzione, codiceFiscale)
	select CURRENT_DATE, codiceFiscale
	from new_user
	returning idImpiegato
)
insert into PrestaServizioIn (idImpiegato, codiceFiliale, dataInizio, dataFine)
select idImpiegato, 1, CURRENT_DATE, null 
from new_employee;

-- QUERY 4: Trasferimento di un Impiegato da una Filiale ad un altra controllando anche i vincoli di trasferimento

insert into prestaservizioin (idImpiegato, codiceFiliale, dataInizio, dataFine) values
(1, 2, CURRENT_DATE, null);

update prestaservizioin 
set dataFine = CURRENT_DATE
where id_Impiegato = 1 and dataFine is null;

-- QUERY 5: Licenziamento di un Impiegato

select * from Impiegato;

delete from Impiegato as i
where i.codiceFiscale = 'GNNVRD90T15F205W';

select * from Impiegato;

-- QUERY 6: Trovare il cliente con l'ammontare totale dei bancomat più alto

select 
	p.codiceFiscale,
	p.nome,
	p.indirizzo
from Persona as p
join Cliente as c on p.codicefiscale = c.codicefiscale 
join IntestatoA as ia on c.codiceFiscale = ia.codiceFiscale
join Conto as co on ia.numeroConto = co.numeroConto 
where co.dataEstinzione is null
group by p.codiceFiscale, p.nome, p.indirizzo
order by sum(co.ammontare) desc
limit 1;

-- QUERY 7: Trova filiali in cui tutte le operazioni registrate sulle sue interfacce sono superiori a 1000 euro

select f.codiceFiliale, f.indirizzo
from filiale as f
join interfaccia as i on f.codicefiliale = i.codicefiliale 
join operazioni as o on o.idinterfaccia = i.idinterfaccia 
group by f.codicefiliale, f.indirizzo 
having MIN(o.ammontare) > 1000;

-- QUERY 8: Trova gli impiegati che sono anche clienti da almeno 5 anni

select distinct
	p.codiceFiscale,
	p.nome,
	p.indirizzo
from impiegato as i
join persona as p on i.codicefiscale = p.codicefiscale 
join cliente as c on p.codicefiscale = c.codicefiscale 
join intestatoA as ia on c.codicefiscale = ia.codicefiscale 
join conto as co on ia.numeroconto = co.numeroconto 
where co.dataapertura <= CURRENT_DATE - interval '5 years';

-- QUERY 9: trova tutte le coppie di clienti che hanno conti intestati nello stesso insieme di filiali

select a.codiceFiscale as cliente1, b.codiceFiscale as cliente2
from cliente as a
join cliente as b on a.codiceFiscale < b.codicefiscale 
where not exists (
	select co.codiceFiliale
	from intestatoa as ia
	join conto as co on ia.numeroconto = co.numeroconto 
	where ia.codicefiscale = a.codicefiscale 
	except 
	select co.codiceFiliale
	from intestatoa as ia
	join conto as co on ia.numeroconto = co.numeroconto 
	where ia.codicefiscale = b.codicefiscale 
)
and not exists (
	select co.codiceFiliale
	from intestatoa as ia
	join conto as co on ia.numeroconto = co.numeroconto 
	where ia.codicefiscale = b.codicefiscale 
	except
	select co.codiceFiliale
	from intestatoa as ia
	join conto as co on ia.numeroconto = co.numeroconto 
	where ia.codicefiscale = a.codicefiscale 
);

