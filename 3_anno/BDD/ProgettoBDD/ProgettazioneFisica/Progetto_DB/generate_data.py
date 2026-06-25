import os
import csv
import random
from faker import Faker
from datetime import timedelta

# Inizializza Faker con localizzazione italiana per avere dati coerenti (es. nomi, indirizzi, CF)
fake = Faker('it_IT')

# --- CONFIGURAZIONE NUMERO ELEMENTI ---
# Usa queste variabili per decidere quanti record generare per ogni tabella.
# Puoi modificarle in base alla necessità di test.
NUM_BANCHE = 5
NUM_FILIALI = 60
NUM_PERSONE = 1000        # Totale persone nel DB
NUM_CLIENTI = 900         # Di cui clienti
NUM_IMPIEGATI = 250       # Di cui impiegati. Avendo 80 + 30 > 100, alcune persone saranno sia clienti che impiegati.
NUM_CONTI = 1200
NUM_INTESTATO_A = 1200    # Relazioni conto-cliente
NUM_PRESTA_SERVIZIO = 400 # Storico servizi impiegati nelle filiali
NUM_CARTE = 1000
NUM_INTERFACCE = 300
NUM_OPERAZIONI = 10000

# --- SEED PER RIPRODUCIBILITÀ (Opzionale) ---
# Rimuovi o commenta per avere dati sempre diversi ad ogni esecuzione
# Faker.seed(42)
# random.seed(42)

def generate_data():
    os.makedirs('data', exist_ok=True)
    print("Inizio generazione dati in formato CSV...")

    # 1. Banca
    nomi_banche = ['Intesa Sanpaolo', 'UniCredit', 'Banca Sella', 'BPER Banca', 'BNL', 'Credem', 'Banco BPM']
    random.shuffle(nomi_banche)
    banche = []
    with open('data/banca.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for i in range(1, NUM_BANCHE + 1):
            nome = nomi_banche[(i - 1) % len(nomi_banche)]
            comm_altri = round(random.uniform(0.5, 3.0), 2)
            # Garantisce che la commissione consorzio sia strettamente minore
            comm_cons = round(random.uniform(0.1, comm_altri - 0.1), 2)
            writer.writerow([i, nome, comm_altri, comm_cons])
            banche.append(i)
    print(f"Generati {NUM_BANCHE} record per Banca")

    # 2. Filiale
    filiali = []
    with open('data/filiale.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for i in range(1, NUM_FILIALI + 1):
            indirizzo = fake.address().replace('\n', ', ')
            banca_ref = random.choice(banche)
            writer.writerow([i, indirizzo, banca_ref])
            filiali.append(i)
    print(f"Generati {NUM_FILIALI} record per Filiale")

    # 3. Persona
    persone_cf = set()
    while len(persone_cf) < NUM_PERSONE:
        cf = fake.ssn()
        persone_cf.add(cf)
            
    persone = list(persone_cf)
    with open('data/persona.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for cf in persone:
            indirizzo = fake.address().replace('\n', ', ')
            nome = fake.name()[:30]  # Tronca a 30 caratteri per il vincolo varchar(30)
            writer.writerow([cf, indirizzo, nome])
    print(f"Generati {NUM_PERSONE} record per Persona")

    # 4. Cliente & 5. Impiegato
    random.shuffle(persone)
    clienti = persone[:NUM_CLIENTI]
    impiegati_cf = persone[-NUM_IMPIEGATI:] 
    
    with open('data/cliente.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for c in clienti:
            writer.writerow([c])
    print(f"Generati {NUM_CLIENTI} record per Cliente")

    impiegati = []
    with open('data/impiegato.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for i, cf in enumerate(impiegati_cf, start=1):
            data_ass = fake.date_between(start_date='-20y', end_date='today')
            writer.writerow([cf, i, data_ass])
            impiegati.append(i)
    print(f"Generati {NUM_IMPIEGATI} record per Impiegato")

    # 6. Conto
    conti = []
    conti_data_apertura = {}
    with open('data/conto.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for i in range(1, NUM_CONTI + 1):
            data_apertura = fake.date_between(start_date='-15y', end_date='-1y')
            data_estinzione = ''
            if random.random() < 0.2: # 20% di probabilità che il conto sia chiuso
                data_estinzione = fake.date_between(start_date=data_apertura + timedelta(days=1), end_date='today')
            ammontare = round(random.uniform(50000.0, 500000.0), 2)
            filiale_ref = random.choice(filiali)
            writer.writerow([i, data_apertura, data_estinzione, ammontare, filiale_ref])
            conti.append(i)
            conti_data_apertura[i] = data_apertura
    print(f"Generati {NUM_CONTI} record per Conto")

    # 7. Intestato_a
    intestazioni = set()
    # Garantisce che ogni conto abbia almeno un intestatario
    for conto in conti:
        c = random.choice(clienti)
        intestazioni.add((c, conto))
    
    # Aggiunge intestatari multipli a random per raggiungere la cifra target
    while len(intestazioni) < NUM_INTESTATO_A:
        c = random.choice(clienti)
        conto = random.choice(conti)
        intestazioni.add((c, conto))
        
    with open('data/intestato_a.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for c, conto in intestazioni:
            writer.writerow([c, conto])
    print(f"Generati {len(intestazioni)} record per Intestato_a")

    # 8. Presta_servizio_in
    # Genera una storia lavorativa sequenziale per ogni impiegato:
    # ogni nuovo trasferimento inizia DOPO la fine del precedente incarico,
    # rispettando il vincolo del trigger (almeno 31 giorni di permanenza minima).
    servizi_rows = []
    for imp in impiegati:
        n_incarichi = random.randint(1, 3)
        # Usa random.sample per evitare la stessa filiale due volte per lo stesso impiegato
        filiali_imp = random.sample(filiali, min(n_incarichi, len(filiali)))
        data_corrente = fake.date_between(start_date='-10y', end_date='-3y')
        for idx, fil in enumerate(filiali_imp):
            data_inizio = data_corrente
            is_ultimo = (idx == len(filiali_imp) - 1)
            if is_ultimo:
                # Ultimo incarico: 50% probabilità che sia ancora attivo
                # Se data_inizio + 31gg è nel futuro, l'impiegato resta attivo per forza
                from datetime import date
                if data_inizio + timedelta(days=31) >= date.today():
                    data_fine = None
                elif random.random() < 0.5:
                    data_fine = None  # Ancora attivo
                else:
                    data_fine = fake.date_between(
                        start_date=data_inizio + timedelta(days=31),
                        end_date='today'
                    )
            else:
                # Incarico storico: deve avere una data_fine
                data_fine = fake.date_between(
                    start_date=data_inizio + timedelta(days=31),
                    end_date=data_inizio + timedelta(days=730)
                )
                # Il prossimo incarico inizia almeno 1 giorno dopo la fine di questo
                data_corrente = data_fine + timedelta(days=random.randint(1, 30))
            servizi_rows.append([imp, fil, data_inizio, data_fine])

    with open('data/presta_servizio_in.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for row in servizi_rows:
            writer.writerow(row)
    print(f"Generati {len(servizi_rows)} record per Presta_servizio_in")

    # 9. CartaBancomat
    carte = []
    intestazioni_list = list(intestazioni)
    num_carte_gen = min(NUM_CARTE, len(intestazioni_list)) # Evita di generare più carte che relazioni possibili
    
    with open('data/cartaBancomat.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for i in range(num_carte_gen):
            c, conto = intestazioni_list[i]
            # PK limitata a 25 caratteri. Usiamo pin lunghi o codici sicuri generati
            pwd = fake.unique.bothify(text='??######')
            # Limiti generosi per sopportare il caricamento bulk (il trigger accumula spesa)
            limite_g = round(random.uniform(5000, 50000), 2)
            limite_m = round(random.uniform(50000, 200000), 2)
            # Spesa iniziale a 0: sarà il trigger update_post_operazione ad accumularla
            spesa_g = 0
            spesa_m = 0
            writer.writerow([pwd, conto, c, limite_g, limite_m, spesa_g, spesa_m])
            carte.append((pwd, conto))
    print(f"Generati {num_carte_gen} record per CartaBancomat")
            
    # 10. Interfaccia
    interfacce = []
    with open('data/interfaccia.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for i in range(1, NUM_INTERFACCE + 1):
            tipo = random.choice(['cassa', 'sportello'])
            disp = round(random.uniform(1000, 50000), 2)
            num_op = random.randint(0, 1000)
            fil = random.choice(filiali)
            writer.writerow([i, tipo, disp, num_op, fil])
            interfacce.append((i, tipo))
    print(f"Generati {NUM_INTERFACCE} record per Interfaccia")

    # 11. Operazione
    with open('data/operazione.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        for i in range(1, NUM_OPERAZIONI + 1):
            id_int, tipo_int = random.choice(interfacce)
            
            # Constraint derivante dall'ER: una Cassa può effettuare solo Deposito e Prelievo
            if tipo_int == 'cassa':
                tipo_op = random.choice(['prelievo', 'deposito'])
            else:
                tipo_op = random.choice(['prelievo', 'deposito', 'saldo', 'lista_movimenti'])
            
            # Ogni operazione richiede una carta bancomat valida
            pwd, conto = random.choice(carte)
            
            # Constraint DB: ammontare >= 0. Le operazioni senza flusso di cassa hanno ammontare NULL
            if tipo_op in ['prelievo', 'deposito']:
                ammontare = round(random.uniform(10, 200), 2)
            else:
                ammontare = None  # NULL
                
            data_ap = conti_data_apertura[conto]
            data_op = fake.date_between(start_date=data_ap, end_date='today')
            ora_op = fake.time()
            
            writer.writerow([i, data_op, ora_op, tipo_op, ammontare, conto, id_int, pwd])
    print(f"Generati {NUM_OPERAZIONI} record per Operazione")
    
    print("\nGenerazione completata con successo! I file CSV sono salvati nella cartella 'data'.")
    print("--------------------------------------------------------------------------------------")
    print("NOTA SULL'IMPORTAZIONE IN POSTGRESQL:")
    print("Dato che le tabelle hanno le PK definite come 'GENERATED ALWAYS AS IDENTITY', hai due opzioni:")
    print("1) Se importi i CSV tenendo gli ID che ho generato in prima colonna:")
    print("   Usa 'OVERRIDING SYSTEM VALUE' (non sempre supportato da \\copy in versioni vecchie, meglio un INSERT da tabella tmp)")
    print("   Oppure temporaneamente cambia le colonne in 'GENERATED BY DEFAULT AS IDENTITY'.")
    print("2) Se vuoi usare \\copy semplice, devi specificare la lista delle colonne da importare escludendo la colonna identity")
    print("   ES: \\copy banca(nomeBanca, commissioneAltri, commissioneConsorzio) FROM 'banca.csv' DELIMITER ',' CSV;")
    print("   Il mio script genera le PK in modo sequenziale partendo da 1, quindi i link referenziali non si corromperanno.")

if __name__ == '__main__':
    generate_data()
