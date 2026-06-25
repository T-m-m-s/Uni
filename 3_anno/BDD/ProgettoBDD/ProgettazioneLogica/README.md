# Modello Logico

## Entità

Banca(**codiceBanca**, nomeBanca, commissioneAltri, commissioneConsorzio)

Filiale(**codiceFiliale**, indirizzo, _codiceBanca(FK)_)

Conto(**numeroConto**, dataApertura, dataEstinzione, ammontare, _codiceFiliale(FK)_)

CartaBancomat(**password**, limiteSpesaGiornaliera, limiteSpesaMensile, spesaGiornaliere, spesaMensile, _numeroConto(FK)_, _cfCliente(FK)_)

Interfaccia(**id**, tipo, disponibilità, numeroOperazioni, _codiceFiliale(FK)_)

Operazioni(**data**, **ora**, _numeroConto(FK)_, tipo, ammontare, _idInterfaccia(FK)_, _passwordBancomat(FK)_)

Persona(**codiceFiscale**, indirizzo, nome)

Cliente(**_codiceFiscale(FK, UNIQUE)_**)

Impiegato(id, dataAssunzione, **_codiceFiscale(FK, UNIQUE)_**)

## Relazioni molti a molti

prestaServizioIn(_impiegato(FK)_, _codiceFiliale(FK)_, dataInizio, dataFine)

intestatoA(_codiceFiscale(FK, UNIQUE)_, _numeroConto(FK)_)

## Vincoli non esprimibili

V1:
```bash
prestaServizioIn.dataFine - prestaServizioIn.dataInizio >= 30
```

V2: 
```bash 
if(conto.dataEstinzione != NULL) then (conto.ammontare == NULL)
```

V3:
```bash
prelievo.importo <= interfaccia.disponibilità
```

V4:
```bash
(cartaBancomat.spesaGiornaliera + prelievo.ammontare) <= cartaBancomat.limiteSpesaGiornaliera

&&

(cartaBancomat.spesaMensile + prelievo.ammontare) <= cartaBancomat.limiteSpesaMensile
```

V5: 
```bash
if(cliente.codiceFiscale = impiegato.codiceFiscale){
    commissione = 0;
}
```

V6:
```bash
if(operazioni.idInterfaccia != NULL){
    commissione = banca.commissioneConsorzio;
}else{
    commissione = banca.commissioneAltri;
}
```

## Note
- L'interfaccia può essere di tipo:
    - Sportello: effettua `deposito`, `prelievo`, `listaMovimenti`, `saldo`.
    - Cassa: effettua `deposito` e `prelievo`(con commmissione).
