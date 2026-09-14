# Ctl_Hub - Breadboard Pinout & Wiring Guide (Layout Simmetrico 3.2")

Questa guida definisce la mappatura completa dei pin per il montaggio su **Breadboard** del Deck con microcontrollore **ESP32-S3 (N16R8)** e **Schermo TFT SPI da 3.2"**.

---

## 📐 Layout Fisico Simmetrico della Console

I componenti sono posizionati simmetricamente ai lati del display centrale da 3.2":

```
┌────────────────────────────────────────────────────────────────────────┐
│  [ BANCO SINISTRO ]            [ SCHERMO TFT 3.2" ]   [ BANCO DESTRO ] │
│                               ┌───────────────────┐                    │
│   ┌─────────────┐             │ 🌐 Profilo Attivo │    ┌─────────────┐ │
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

---

## ⚠️ Note Critiche di Sicurezza sull'ESP32-S3 (N16R8)

1. **PSRAM e Flash Interne (Vietate):**
   L'ESP32-S3 con 16MB Flash e 8MB Octal PSRAM (N16R8) utilizza internamente i pin **GPIO da 26 a 37**.
   > **NON collegare MAI nulla ai GPIO 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37**, pena il blocco immediato (boot loop) o il danneggiamento della memoria.
2. **USB Nativa (CDC):**
   I pin **GPIO 19 (D-)** e **GPIO 20 (D+)** sono riservati alla porta USB-C nativa per la programmazione e la comunicazione seriale CDC con il PC Linux.
3. **Resistori di Pull-Up Interni:**
   Tutti i pulsanti meccanici e gli switch degli encoder utilizzano le **resistenze di pull-up interne all'ESP32 (`INPUT_PULLUP`)**. Non serve aggiungere resistori esterni sulla breadboard.

---

## 1. Tabella Mappatura Pin Completa

### Banco Sinistro (Pulsanti K1-K3 & Knob 0)
| Componente Fisico | Segnale | Pin ESP32-S3 | Modalità Firmware | Note di Cablaggio |
| :--- | :--- | :--- | :--- | :--- |
| **K1 (Top Left)** | Switch Pin 1 | **GPIO 4** | `INPUT_PULLUP` | Altro pin dello switch a **GND** |
| **K2 (Mid Left)** | Switch Pin 1 | **GPIO 5** | `INPUT_PULLUP` | Altro pin dello switch a **GND** |
| **K3 (Bot Left)** | Switch Pin 1 | **GPIO 6** | `INPUT_PULLUP` | Altro pin dello switch a **GND** |
| **Knob 0 (Volume)** | CLK (A) | **GPIO 17** | `INPUT_PULLUP` | Segnale encoder A |
| | DT (B) | **GPIO 18** | `INPUT_PULLUP` | Segnale encoder B |
| | SW (Click) | **GPIO 8** | `INPUT_PULLUP` | Click = Mute / LongPress = Profilo |
| | VCC (+) | **3.3V** | Alimentazione | Guida 3.3V breadboard |
| | GND (-) | **GND** | Massa | Guida GND comune |

### Display Centrale (TFT SPI 3.2" - ILI9341 / 320x240)
| Segnale Display | Pin ESP32-S3 | Modalità Firmware | Note di Cablaggio |
| :--- | :--- | :--- | :--- |
| **VCC** | **3.3V o 5V** | Alimentazione | Controllare serigrafia modulo LCD |
| **GND** | **GND** | Massa | Guida GND comune |
| **CS (Chip Select)** | **GPIO 14** | `OUTPUT` | SPI Chip Select |
| **RESET (RST)** | **GPIO 38** | `OUTPUT` | Reset hardware display |
| **DC / RS (Data/Cmd)**| **GPIO 21** | `OUTPUT` | Selezione Registro Dati |
| **SDI / MOSI** | **GPIO 13** | `SPI MOSI` | Bus dati SPI (FSPI) |
| **SCK / CLK** | **GPIO 12** | `SPI SCK` | Clock bus SPI (FSPI) |
| **LED / BLK** | **GPIO 48** | `OUTPUT / PWM` | Retroilluminazione (o 3.3V fissa) |
| **SDO / MISO** | **GPIO 1** | `SPI MISO` | Opzionale |

### Banco Destro (Pulsanti K4-K6 & Knob 1)
| Componente Fisico | Segnale | Pin ESP32-S3 | Modalità Firmware | Note di Cablaggio |
| :--- | :--- | :--- | :--- | :--- |
| **K4 (Top Right)** | Switch Pin 1 | **GPIO 7** | `INPUT_PULLUP` | Altro pin dello switch a **GND** |
| **K5 (Mid Right)** | Switch Pin 1 | **GPIO 15** | `INPUT_PULLUP` | Altro pin dello switch a **GND** |
| **K6 (Bot Right)** | Switch Pin 1 | **GPIO 16** | `INPUT_PULLUP` | Altro pin dello switch a **GND** |
| **Knob 1 (Microfono)**| CLK (A) | **GPIO 9** | `INPUT_PULLUP` | Segnale encoder A |
| | DT (B) | **GPIO 10** | `INPUT_PULLUP` | Segnale encoder B |
| | SW (Click) | **GPIO 11** | `INPUT_PULLUP` | Click = Mute Mic |
| | VCC (+) | **3.3V** | Alimentazione | Guida 3.3V breadboard |
| | GND (-) | **GND** | Massa | Guida GND comune |

---

## 2. Note di Montaggio su Breadboard

* **Massa Comune (GND):** Collega insieme tutti i pin di massa sulla barra blu (-) della breadboard.
* **Tasti Meccanici:** Non hanno polarità. Un piedino va al rispettivo GPIO, l'altro direttamente a GND.
* **Rotary Encoders (KY-040):** VCC va alla guida 3.3V (non 5V, per non superare i livelli logici dei GPIO ESP32).
