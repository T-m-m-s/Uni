#!/bin/bash

# Script di test per verificare il setup del DB (schema, vincoli, logica, dati)
# Esegue gli script SQL in sequenza.

set -e

# --- Colori per l'output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

pass() { echo -e "  ${GREEN}✔  [OK]${NC}    $1"; }
fail() { echo -e "  ${RED}✖  [FAIL]${NC}  $1"; }
info() { echo -e "${BLUE}${BOLD}==>${NC} ${BOLD}$1${NC}"; }
step() { echo -e "  ${YELLOW}▶${NC}  $1"; }

echo -e "${BOLD}==================================================${NC}"
echo -e "${BOLD}           TEST SETUP DATABASE${NC}"
echo -e "${BOLD}==================================================${NC}"
echo ""

# --- Configurazione ---
info "Configurazione Ambiente"
if [ ! -f config.env ]; then
    if [ -f config.env.example ]; then
        step "config.env non trovato, copio dal template..."
        cp config.env.example config.env
        pass "config.env creato da config.env.example"
        echo -e "      ${YELLOW}--> Modifica config.env con le tue credenziali se necessario.${NC}"
    else
        fail "Nessun config.env o config.env.example trovato"
        exit 1
    fi
fi
set -a; source config.env; set +a
pass "Variabili d'ambiente caricate"

# Se la password è vuota, chiedi interattivamente
if [ -z "$PGPASSWORD" ]; then
    echo -n "Password per l'utente PostgreSQL '$DB_USER': "
    read -rs PGPASSWORD
    echo
    export PGPASSWORD
fi
echo ""

# --- Verifica connessione ---
info "Verifica Connessione"
if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c '\q' 2>/dev/null; then
    pass "Connessione a PostgreSQL riuscita"
else
    fail "Impossibile connettersi a PostgreSQL (host=$DB_HOST port=$DB_PORT user=$DB_USER)"
    exit 1
fi
echo ""

# --- Generazione CSV se assenti ---
info "Preparazione Dati"
if [ -z "$(ls -A data/*.csv 2>/dev/null)" ]; then
    step "Nessun CSV trovato in 'data/', avvio generazione dati..."
    python3 generate_data.py
    pass "Dati generati"
else
    pass "CSV già presenti in 'data/', uso quelli esistenti"
fi
echo ""

echo -e "${BOLD}--------------------------------------------------${NC}"
echo -e "${BOLD}        ESECUZIONE SCRIPT SQL${NC}"
echo -e "${BOLD}--------------------------------------------------${NC}"
echo ""

# Per nascondere l'output di default di psql mantenendo solo gli errori
QUIET_PSQL="-q"

# --- 00: Inizializzazione DB ---
info "Fase 0: Inizializzazione DB"
step "Esecuzione 00_init_db.sql (drop + create database)..."
envsubst < "$SQL_DIR/00_init_db.sql" | psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres $PSQL_OPTIONS $QUIET_PSQL
pass "Database '$DB_NAME' ricreato"
echo ""

# --- 01: Schema ---
info "Fase 1: Schema"
step "Esecuzione 01_schema.sql..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" $PSQL_OPTIONS $QUIET_PSQL -f "$SQL_DIR/01_schema.sql"
pass "Schema applicato"
echo ""

# --- 02: Constraints ---
info "Fase 2: Constraints"
step "Esecuzione 02_constraints.sql..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" $PSQL_OPTIONS $QUIET_PSQL -f "$SQL_DIR/02_constraints.sql"
pass "Vincoli e indici applicati"
echo ""

# --- 03: Logica ---
info "Fase 3: Logica"
step "Esecuzione 03_logic.sql..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" $PSQL_OPTIONS $QUIET_PSQL -f "$SQL_DIR/03_logic.sql"
pass "Funzioni e trigger caricati"
echo ""

# --- 04: Dati ---
info "Fase 4: Dati"
step "Esecuzione 04_data.sql (caricamento CSV)..."
envsubst < "$SQL_DIR/04_data.sql" | psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" $PSQL_OPTIONS $QUIET_PSQL
pass "Dati caricati"
echo ""

# --- 05: Queries ---
info "Fase 5: Queries"
step "Esecuzione 05_queries.sql..."
# Qui non usiamo QUIET_PSQL per mostrare l'output delle query all'utente
envsubst < "$SQL_DIR/05_queries.sql" | psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" $PSQL_OPTIONS
pass "Queries eseguite"
echo ""

# --- Verifica conteggi ---
# echo "--------------------------------------------------"
# info "Verifica conteggi per tabella..."
# psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" --tuples-only --no-align -c "
# SET search_path TO consorzio;
# SELECT 'banca'               , count(*) FROM banca              UNION ALL
# SELECT 'filiale'             , count(*) FROM filiale            UNION ALL
# SELECT 'persona'             , count(*) FROM persona            UNION ALL
# SELECT 'cliente'             , count(*) FROM cliente            UNION ALL
# SELECT 'impiegato'           , count(*) FROM impiegato          UNION ALL
# SELECT 'conto'               , count(*) FROM conto              UNION ALL
# SELECT 'intestato_a'         , count(*) FROM intestato_a        UNION ALL
# SELECT 'presta_servizio_in'  , count(*) FROM presta_servizio_in UNION ALL
# SELECT 'cartaBancomat'       , count(*) FROM cartaBancomat      UNION ALL
# SELECT 'interfaccia'         , count(*) FROM interfaccia        UNION ALL
# SELECT 'operazione'          , count(*) FROM operazione;
# " | column -t -s '|'
# echo ""

echo -e "${BOLD}==================================================${NC}"
pass "Setup completato con successo!"
echo -e "${BOLD}==================================================${NC}"
