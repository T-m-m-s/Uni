set search_path to consorzio;

\echo ''
\echo '======================================================================'
\echo ' QUERY 1: Restituisce informazioni su una data interfaccia (ex. 1)'
\echo '======================================================================'

select * 
from interfaccia as i
where i.idInterfaccia = 1;

\echo ''
\echo '======================================================================'
\echo ' QUERY 2: Inserimento di una operazione (di prelievo 50)'
\echo ' da un conto (120) con bancomat (Ee450079) su una interfaccia (26)'
\echo '======================================================================'

insert into operazione (dataOperazione, oraOperazione, tipo, ammontare, numeroConto_o, idInterfaccia_o, passwordBancomat_o) values
(CURRENT_DATE, CURRENT_TIME, 'prelievo', 50.00, 120, 26, 'Ee450079');

select * from operazione
where numeroConto_o = 120;

\echo ''
\echo '======================================================================'
\echo ' QUERY 3: Assunzione di un nuovo impiegato in una filiale'
\echo '======================================================================'

with new_user as (
	insert into Persona (codiceFiscale, nome, indirizzo) values 
	('BNCMRR92L10H501T', 'Bianca Rossi', 'Via delle Scienze 208, Udine')
	on conflict (codiceFiscale) do update
		set codiceFiscale = EXCLUDED.codiceFiscale
	returning codiceFiscale
),
new_employee as (
	insert into Impiegato (dataAssunzione, codiceFiscale_i)
	select CURRENT_DATE, codiceFiscale
	from new_user
	returning idImpiegato
)
insert into presta_servizio_in (idImpiegato_psi, codiceFiliale_psi, dataInizio, dataFine)
select idImpiegato, 1, CURRENT_DATE, null 
from new_employee;

select * from impiegato
where codiceFiscale_i = 'BNCMRR92L10H501T';
select * from presta_servizio_in
where idImpiegato_psi = 251;

\echo ''
\echo '======================================================================'
\echo ' QUERY 4: Trasferimento di un Impiegato da una Filiale ad un altra'
\echo ' controllando anche i vincoli di trasferimento'
\echo '======================================================================'

select * from presta_servizio_in
where idImpiegato_psi = 9;

update presta_servizio_in 
set dataFine = CURRENT_DATE
where idImpiegato_psi = 9 and dataFine is null;

insert into presta_servizio_in (idImpiegato_psi, codiceFiliale_psi, dataInizio, dataFine) values
(9, 37, CURRENT_DATE, null);

select * from presta_servizio_in
where idImpiegato_psi = 9;

\echo ''
\echo '======================================================================'
\echo ' QUERY 5: Licenziamento di un Impiegato'
\echo '======================================================================'

select * from Impiegato
where codiceFiscale_i = 'PNITZN84C68I891X';

delete from Impiegato as i
where i.codiceFiscale_i = 'PNITZN84C68I891X';

select * from Impiegato
where codiceFiscale_i = 'PNITZN84C68I891X';

\echo ''
\echo '======================================================================'
\echo ' QUERY 6: Trovare il cliente con l''ammontare complessivo dei conti correnti intestati più alto'
\echo '======================================================================'

select 
	p.codiceFiscale,
	p.nome,
	p.indirizzo,
	sum(co.ammontare)
from persona as p
join cliente as c on p.codicefiscale = c.codiceFiscale_c 
join intestato_a as ia on c.codiceFiscale_c = ia.codiceFiscale_int
join conto as co on ia.numeroConto_int = co.numeroConto 
where co.dataEstinzione is null
group by p.codiceFiscale, p.nome, p.indirizzo
order by sum(co.ammontare) desc
limit 1;

\echo ''
\echo '======================================================================'
\echo ' QUERY 7: Trova filiali in cui tutte le operazioni registrate'
\echo ' sulle sue interfacce sono superiori a 20 euro'
\echo '======================================================================'

select f.codiceFiliale, f.indirizzo
from filiale as f
join interfaccia as i on f.codicefiliale = i.codiceFiliale_i 
join operazione as o on o.idInterfaccia_o = i.idinterfaccia 
group by f.codicefiliale, f.indirizzo 
having MIN(o.ammontare) > 20;

\echo ''
\echo '======================================================================'
\echo ' QUERY 8: Trova gli impiegati che sono anche clienti da almeno 13 anni'
\echo '======================================================================'

select distinct
	p.codiceFiscale,
	p.nome,
	p.indirizzo
from impiegato as i
join persona as p on i.codiceFiscale_i = p.codicefiscale 
join cliente as c on p.codicefiscale = c.codiceFiscale_c 
join intestato_a as ia on c.codiceFiscale_c = ia.codiceFiscale_int 
join conto as co on ia.numeroConto_int = co.numeroconto 
where co.dataapertura <= CURRENT_DATE - interval '13 years';

\echo ''
\echo '======================================================================'
\echo ' QUERY 9: Trova tutte le coppie di clienti che hanno conti'
\echo ' intestati nello stesso insieme di filiali (almeno 2)'
\echo '======================================================================'

select a.codiceFiscale_c as cliente1, b.codiceFiscale_c as cliente2
from cliente as a
join cliente as b on a.codiceFiscale_c < b.codiceFiscale_c 
where (
	select count(distinct co.filialeReferente)
	from intestato_a as ia
	join conto as co on ia.numeroConto_int = co.numeroconto 
	where ia.codiceFiscale_int = a.codiceFiscale_c
) >= 2
and not exists (
	select co.filialeReferente
	from intestato_a as ia
	join conto as co on ia.numeroConto_int = co.numeroconto 
	where ia.codiceFiscale_int = a.codiceFiscale_c 
	except 
	select co.filialeReferente
	from intestato_a as ia
	join conto as co on ia.numeroConto_int = co.numeroconto 
	where ia.codiceFiscale_int = b.codiceFiscale_c 
)
and not exists (
	select co.filialeReferente
	from intestato_a as ia
	join conto as co on ia.numeroConto_int = co.numeroconto 
	where ia.codiceFiscale_int = b.codiceFiscale_c 
	except
	select co.filialeReferente
	from intestato_a as ia
	join conto as co on ia.numeroConto_int = co.numeroconto 
	where ia.codiceFiscale_int = a.codiceFiscale_c 
);
