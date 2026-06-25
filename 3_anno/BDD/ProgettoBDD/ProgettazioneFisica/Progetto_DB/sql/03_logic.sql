set search_path to consorzio;

-- FUNZIONI

CREATE OR REPLACE FUNCTION consorzio.check_correttezza_carta()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    conto_associato INTEGER;
BEGIN
    SELECT numeroConto_cb INTO conto_associato
    FROM cartaBancomat
    WHERE passwordBancomat = NEW.passwordBancomat_o;

	IF conto_associato IS NULL THEN
        RAISE EXCEPTION 'Password % non in sistema', NEW.passwordBancomat_o;
    END IF;

    IF conto_associato != NEW.numeroConto_o THEN
        RAISE EXCEPTION 'Allarme Sicurezza: La carta utilizzata non è autorizzata ad operare sul conto %.', NEW.numeroConto_o;
    END IF;

    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION consorzio.check_trasferimento_insert()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    lavori_precedenti INT;
    ultimo_inizio DATE;
BEGIN
    IF EXISTS (
        SELECT 1 FROM presta_servizio_in
        WHERE idImpiegato_psi = NEW.idImpiegato_psi AND codiceFiliale_psi = NEW.codiceFiliale_psi
    ) THEN 
        RAISE EXCEPTION 'Trasferimento Negato: l''impiegato % ha già prestato servizio nella filiale %.', NEW.idImpiegato_psi, NEW.codiceFiliale_psi;
    END IF;

    SELECT COUNT(*) INTO lavori_precedenti FROM presta_servizio_in WHERE idImpiegato_psi = NEW.idImpiegato_psi;
    
    IF lavori_precedenti > 0 THEN
        SELECT MAX(dataInizio) INTO ultimo_inizio FROM presta_servizio_in WHERE idImpiegato_psi = NEW.idImpiegato_psi;
        
        IF (NEW.dataInizio < ultimo_inizio + INTERVAL '1 month') THEN
            RAISE EXCEPTION 'Trasferimento Negato: l''impiegato % non ha superato il mese di permanenza minimo.', NEW.idImpiegato_psi;
        END IF;
    END IF;

    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION consorzio.calcola_commissione_prelievo(
    p_numeroConto INT, 
    p_idInterfaccia INT
) RETURNS NUMERIC 
LANGUAGE plpgsql
AS $$
DECLARE
    v_banca_conto INT;
    v_banca_atm INT;
    v_costo_consorzio NUMERIC;
    v_costo_altri NUMERIC;
BEGIN
    SELECT b.codiceBanca, b.commissioneConsorzio, b.commissioneAltri 
    INTO v_banca_conto, v_costo_consorzio, v_costo_altri
    FROM conto c
    JOIN filiale f ON c.filialeReferente = f.codiceFiliale
    JOIN banca b ON f.bancaReferente = b.codiceBanca
    WHERE c.numeroConto = p_numeroConto;
    IF p_idInterfaccia IS NOT NULL THEN
        SELECT f.bancaReferente INTO v_banca_atm
        FROM interfaccia i
        JOIN filiale f ON i.codiceFiliale_i = f.codiceFiliale
        WHERE i.idInterfaccia = p_idInterfaccia;
        
        IF v_banca_conto = v_banca_atm THEN
            RETURN 0.00;
        ELSE
            RETURN v_costo_consorzio;
        END IF;
    ELSE
        RETURN v_costo_altri;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION consorzio.check_prelievo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
	ammontare_attuale NUMERIC(17,2);
	disponibilita_attuale NUMERIC(8,2);
	carta RECORD;
	commissione NUMERIC(4,2) := 0;
begin
	if new.tipo = 'prelievo' then
		commissione = consorzio.calcola_commissione_prelievo(new.numeroConto_o, new.idInterfaccia_o);
		select ammontare into ammontare_attuale
		from conto
		where numeroConto = new.numeroConto_o;

		if (new.ammontare + commissione) > ammontare_attuale then
			raise exception 'Operazione Negata: saldo insufficiente sul conto % (Prelievo: %, Commissione: %).', new.numeroConto_o, new.ammontare, commissione;
		end if;

		if new.idInterfaccia_o is not null then
			select disponibilita into disponibilita_attuale
			from interfaccia
			where idInterfaccia = new.idInterfaccia_o;

			if new.ammontare > disponibilita_attuale then
				raise exception 'Operazione Negata: saldo insufficiente sull''Interfaccia %', new.idInterfaccia_o;
			end if;
		end if;

		select * into carta
		from cartaBancomat
		where passwordBancomat = new.passwordBancomat_o;

		if (carta.spesaGiornaliera + new.ammontare) > carta.limiteSpesaGiornaliero then
			raise exception 'Operazione Negata: Importo superiore al limite giornaliero disponibile.';
		end if;

		if (carta.spesaMensile + new.ammontare) > carta.limiteSpesaMensile then
			raise exception 'Operazione Negata: Importo superiore al limite mensile disponibile.';
		end if;
	end if;

	return new;
end;
$function$;

CREATE OR REPLACE FUNCTION consorzio.update_post_operazione()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
	commissione NUMERIC(4,2) := 0;
begin
	update interfaccia
	set numeroOperazioni = numeroOperazioni + 1
	where idInterfaccia = new.idInterfaccia_o;

	if new.tipo = 'prelievo' then
		commissione = consorzio.calcola_commissione_prelievo(new.numeroConto_o, new.idInterfaccia_o);
		update conto set ammontare = ammontare - (new.ammontare + commissione) where numeroConto = new.numeroConto_o;
		
		if new.idInterfaccia_o is not null then
			update interfaccia set disponibilita = disponibilita - new.ammontare where idInterfaccia = new.idInterfaccia_o;
		end if;

		update cartaBancomat
		set spesaGiornaliera = spesaGiornaliera + new.ammontare,
		    spesaMensile = spesaMensile + new.ammontare
		where passwordBancomat = new.passwordBancomat_o;

	elsif new.tipo = 'deposito' then
		update conto set ammontare = ammontare + new.ammontare where numeroConto = new.numeroConto_o;
		
		if new.idInterfaccia_o is not null then
			update interfaccia set disponibilita = disponibilita + new.ammontare where idInterfaccia = new.idInterfaccia_o;
		end if;
	end if;

	return new;
end;
$function$;

CREATE OR REPLACE FUNCTION consorzio.check_conto_estinto()
    returns trigger as $$
        declare 
            v_data_estinzione DATE;
        begin
            select dataEstinzione into v_data_estinzione 
            from conto
            where numeroConto = NEW.numeroConto_o;

            if v_data_estinzione is not null then 
                raise exception 'Operazione Negata: Il conto % è stato estinto il %.', NEW.numeroConto_o, v_data_estinzione;
            end if;

            return new;
        end;
    $$ language plpgsql;

CREATE OR REPLACE FUNCTION consorzio.gestione_conto_estinto()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.dataEstinzione IS NOT NULL THEN
            NEW.ammontare := NULL;
            DELETE FROM consorzio.operazione WHERE passwordBancomat_o IN (SELECT passwordBancomat FROM consorzio.cartaBancomat WHERE numeroConto_cb = NEW.numeroConto);
            DELETE FROM consorzio.cartaBancomat WHERE numeroConto_cb = NEW.numeroConto;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.dataEstinzione IS NOT NULL AND OLD.dataEstinzione IS NULL THEN
            NEW.ammontare := NULL;
            DELETE FROM consorzio.operazione WHERE passwordBancomat_o IN (SELECT passwordBancomat FROM consorzio.cartaBancomat WHERE numeroConto_cb = NEW.numeroConto);
            DELETE FROM consorzio.cartaBancomat WHERE numeroConto_cb = NEW.numeroConto;
        END IF;
    END IF;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION consorzio.check_operazione_cassa()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_tipo_interfaccia tipo_interfaccia;
BEGIN
    SELECT tipo INTO v_tipo_interfaccia
    FROM consorzio.interfaccia
    WHERE idInterfaccia = NEW.idInterfaccia_o;

    IF v_tipo_interfaccia = 'cassa' AND NEW.tipo NOT IN ('prelievo', 'deposito') THEN
        RAISE EXCEPTION 'Operazione Negata: l''interfaccia di tipo cassa (ID %) supporta solo operazioni di prelievo e deposito.', NEW.idInterfaccia_o;
    END IF;

    RETURN NEW;
END;
$function$;

-- TRIGGER

create trigger trg_gestione_conto_estinto before insert or update
    on consorzio.conto
    for each row execute function consorzio.gestione_conto_estinto();

create trigger trg_check_operazione_cassa before insert
    on consorzio.operazione 
    for each row execute function consorzio.check_operazione_cassa();

create trigger trg_correttezza_carta before insert
    on consorzio.operazione 
    for each row execute function consorzio.check_correttezza_carta();

create trigger trg_check_trasferimento_insert before insert
    on consorzio.presta_servizio_in 
    for each row execute function consorzio.check_trasferimento_insert();

create trigger trg_blocco_prelievo before insert
    on consorzio.operazione 
    for each row execute function consorzio.check_prelievo();

create trigger trg_update_post_op after insert
    on consorzio.operazione 
    for each row execute function consorzio.update_post_operazione();

create trigger trg_check_conto_estinto before insert
    on consorzio.operazione
    for each row execute function consorzio.check_conto_estinto();