create schema if not exists consorzio;
set search_path to consorzio;

create type tipo_interfaccia as enum ('cassa', 'sportello');
create type tipo_operazione as enum ('prelievo', 'deposito', 'saldo', 'lista_movimenti');

-- CREAZIONE TABELLE

create table banca (
    codiceBanca integer generated always as identity primary key,
    nomeBanca varchar(50) not null,
    commissioneAltri numeric(4, 2) not null,
    commissioneConsorzio numeric(4, 2) not null
);

create table filiale (
    codiceFiliale integer generated always as identity primary key,
    indirizzo varchar(100) not null,
    bancaReferente integer not null,
    foreign key (bancaReferente) references banca(codiceBanca)
);

create table persona (
    codiceFiscale varchar(16) primary key,
    indirizzo varchar(100) not null,
    nome varchar(30) not null
);

create table cliente (
    codiceFiscale_c varchar(16) primary key references persona(codiceFiscale) ON DELETE CASCADE
);

create table impiegato (
    codiceFiscale_i varchar(16) primary key references persona(codiceFiscale) ON DELETE CASCADE,
    idImpiegato integer generated always as identity unique,
    dataAssunzione date not null
);

create table conto (
    numeroConto integer generated always as identity primary key,
    dataApertura date not null,
    dataEstinzione date,
    ammontare numeric(17,2),
    filialeReferente integer not null,
    foreign key (filialeReferente) references filiale(codiceFiliale)
);

create table intestato_a (
    codiceFiscale_int varchar(16),
    numeroConto_int integer,
    primary key (codiceFiscale_int, numeroConto_int),
    foreign key (codiceFiscale_int) references cliente(codiceFiscale_c) ON DELETE CASCADE,
    foreign key (numeroConto_int) references conto(numeroConto) ON DELETE CASCADE
);

create table presta_servizio_in (
    idImpiegato_psi integer,
    codiceFiliale_psi integer,
    dataInizio date not null,
    dataFine date,
    primary key (idImpiegato_psi, codiceFiliale_psi),
    foreign key (idImpiegato_psi) references impiegato(idImpiegato) ON DELETE CASCADE,
    foreign key (codiceFiliale_psi) references filiale(codiceFiliale) ON DELETE CASCADE
);

create table cartaBancomat (
    passwordBancomat varchar(25) primary key,
    numeroConto_cb integer not null,
    codiceFiscale_cb varchar(16) not null,

    limiteSpesaGiornaliero numeric(10, 2) not null,
    limiteSpesaMensile numeric(14, 2) not null,

    spesaGiornaliera numeric(10, 2) default 0 not null,
    spesaMensile numeric(14, 2) default 0 not null,

    foreign key (numeroConto_cb) references conto(numeroConto) ON DELETE CASCADE,
    foreign key (codiceFiscale_cb) references cliente(codiceFiscale_c) ON DELETE CASCADE
);

create table interfaccia (
    idInterfaccia integer generated always as identity primary key,
    tipo tipo_interfaccia not null,
    disponibilita numeric(10, 2) not null,
    numeroOperazioni integer not null default 0,
    codiceFiliale_i integer not null,
    foreign key (codiceFiliale_i) references filiale(codiceFiliale)
);

create table operazione (
    idOperazione integer generated always as identity primary key,
    dataOperazione date default CURRENT_DATE not null,
    oraOperazione time default CURRENT_TIME not null,
    tipo tipo_operazione not null,
    ammontare numeric(10,2),
    numeroConto_o integer not null,
    idInterfaccia_o integer not null,
    passwordBancomat_o varchar(25) not null,
    foreign key (numeroConto_o) references conto(numeroConto),
    foreign key (idInterfaccia_o) references interfaccia(idInterfaccia),
    foreign key (passwordBancomat_o) references cartaBancomat(passwordBancomat) ON DELETE CASCADE
);