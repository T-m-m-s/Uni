set search_path to consorzio;

create index idx_filiale_banca_fk on filiale(bancaReferente);
create index idx_conto_filiale_fk on conto(filialeReferente);

create index idx_interfaccia_filiale_fk on interfaccia(codiceFiliale_i);
create index idx_operazione_conto_fk on operazione(numeroConto_o);
create index idx_operazione_interfaccia on operazione(idInterfaccia_o);

create index idx_intestato_conto_fk on intestato_a(numeroConto_int);

-- per query 6 e 8
create index idx_conto_attivo_data on conto(dataApertura) where dataEstinzione is null;

-- per query 7
create index idx_operazione_ammontare_val on operazione(ammontare);

-- per query 4
create index idx_servizio_attivo on presta_servizio_in(idImpiegato_psi) where dataFine is null;

alter table operazione
    add constraint chk_ammontare_positivo
    check (ammontare >= 0);

alter table presta_servizio_in
    add constraint chk_date
    check (dataFine is null or dataFine >= dataInizio);