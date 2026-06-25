
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

