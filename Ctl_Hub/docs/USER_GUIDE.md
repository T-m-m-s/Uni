# Ctl_Hub - Guida Utente e Manuale Operativo

Guida all'uso, mappatura dei controlli fisici e configurazione delle macro per la console **Ctl_Hub (ESP32-S3 + Linux Host)**.

---

## 1. Mappatura dei Controlli Fisici

```
┌────────────────────────────────────────────────────────────────────────┐
│  [ BANCO SINISTRO ]            [ SCHERMO TFT 3.2" ]   [ BANCO DESTRO ] │
│                               ┌───────────────────┐                    │
│   ┌─────────────┐             │ Profilo Attivo    │    ┌─────────────┐ │
│   │ K1: Browser │             ├─────────┬─────────┤    │ K4: Mute Out│ │
│   └─────────────┘             │ K1: ... │ K4: ... │    └─────────────┘ │
│   ┌─────────────┐             │ K2: ... │ K5: ... │    ┌─────────────┐ │
│   │ K2: Discord │             │ K3: ... │ K6: ... │    │ K5: Mute Mic│ │
│   └─────────────┘             ├─────────┴─────────┤    └─────────────┘ │
│   ┌─────────────┐             │ CPU: 12%  RAM: 38%│    ┌─────────────┐ │
│   │ K3: Terminal│             └───────────────────┘    │ K6: Screen  │ │
│   └─────────────┘                                      └─────────────┘ │
│        ( 0 )                                                ( 1 )      │
│    Knob 0 (Volume)                                       Knob 1 (Mic)  │
└────────────────────────────────────────────────────────────────────────┘
```

### A. I 6 Tasti Meccanici (K1 - K6)
* **Pressione Singola:** Esegue immediatamente la macro o il comando shell associato al tasto nel profilo attivo.
* **Feedback Grafico:**
  * I tasti di sinistra (**K1, K2, K3**) corrispondono alla colonna sinistra dello schermo.
  * I tasti di destra (**K4, K5, K6**) corrispondono alla colonna destra dello schermo.
  * Alla pressione, la relativa card sul display TFT si illumina in tempo reale evidenziando l'avvenuta attivazione.

### B. Knob 0 (Encoder Sinistro - Volume Principale & Switch Profili)
* **Rotazione Oraria:** Incrementa il volume di sistema di +5% (`wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+`).
* **Rotazione Antioraria:** Riduce il volume di sistema di -5% (`wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-`).
* **Click Breve:** Commuta il Mute dell'uscita audio (`wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle`).
* **Pressione Prolungata (Long Press > 0.7s):** **Cambio Profilo.** Cicla automaticamente al profilo successivo (`Generale` -> `Dev & Uni` -> `Media & Stream`).

### C. Knob 1 (Encoder Destro - Volume Microfono & Reset Display)
* **Rotazione Oraria:** Incrementa il volume del microfono di +5% (`wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+`).
* **Rotazione Antioraria:** Riduce il volume del microfono di -5% (`wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-`).
* **Click Breve:** Commuta il Mute del microfono (`wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle`).
* **Pressione Prolungata (Long Press > 0.7s):** **Reset Hardware Display.** Re-inizializza il controller SPI ILI9341 e ridisegna l'interfaccia a schermo per recuperare da falsi contatti o glitch grafici senza riavviare il dispositivo.

---

## 2. Installazione del Pacchetto Host (`ctlhub`)

### Metodo Automatico Consigliato
Dalla directory root del repository:
```bash
./install.sh
```
Lo script verifica la presenza di Python 3 e `pipx`, installa il pacchetto `ctlhub` in modalità editabile, copia le regole udev in `/etc/udev/rules.d/` e offre la configurazione opzionale del servizio utente systemd per l'avvio automatico all'accensione del PC.

### Metodo Manuale con pipx
```bash
pipx install --editable ./Host --force
sudo cp Host/udev/99-ctlhub.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
```

---

## 3. Gestione Profili & Web Studio

### Interfaccia Grafica Locale
Avvia l'editor web con:
```bash
ctlhub gui
```
Si aprirà automaticamente `http://127.0.0.1:8765` nel browser:
* Visualizzazione interattiva della console Ctl_Hub.
* Modifica delle etichette e dei comandi associati a ciascun tasto.
* Selezione del colore del tema del profilo.
* Sincronizzazione istantanea con la memoria flash LittleFS dell'ESP32 tramite il pulsante "Salva & Sincronizza".

### Modifica Manuale del File JSON
I profili sono archiviati in [`Config/esp32_config.json`](../Config/esp32_config.json):

```json
{
  "id": "gaming",
  "name": "Gaming",
  "theme_color": "#E53935",
  "keys": [
    {"id": 0, "name": "Steam", "cmd": "steam"},
    {"id": 1, "name": "Discord", "cmd": "vesktop"},
    {"id": 2, "name": "Terminale", "cmd": "foot"},
    {"id": 3, "name": "Mute Audio", "cmd": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"},
    {"id": 4, "name": "Mute Mic", "cmd": "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"},
    {"id": 5, "name": "Screenshot", "cmd": "grim -g \"$(slurp)\" - | wl-copy"}
  ],
  "knobs": {
    "knob_0": {"rotate_action": "volume_out", "click_cmd": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"},
    "knob_1": {"rotate_action": "volume_mic", "click_cmd": "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"}
  }
}
```

Per applicare modifiche manuali senza usare la GUI:
```bash
ctlhub sync Config/esp32_config.json
```

---

## 4. Controllo da Riga di Comando (CLI)

```bash
# Lista profili disponibili
ctlhub profile list

# Passa al profilo successivo / precedente
ctlhub next
ctlhub prev

# Commuta a un profilo specifico
ctlhub switch coding
ctlhub switch 1

# Invia segnale di re-inizializzazione del display
ctlhub reinit

# Arresta il servizio o demone in background
ctlhub kill
```
