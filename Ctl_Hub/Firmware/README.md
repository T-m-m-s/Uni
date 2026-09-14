# Ctl_Hub - Embedded ESP32-S3 Firmware

This directory contains the embedded C++ firmware for the **Ctl_Hub** Stream Deck console, managed using [PlatformIO](https://platformio.org/).

---

## 1. Hardware & Memory Configuration

The firmware is targeted for the **ESP32-S3 DevKitC-1 (N16R8)** variant:
* **Flash:** 16 MB SPI Flash
* **PSRAM:** 8 MB Octal SPI PSRAM (`qio_opi`)
* **Display Driver:** [LovyanGFX](https://github.com/lovyan03/LovyanGFX) configured for SPI ILI9341 (320x240, 20 MHz SPI clock, landscape rotation 1)
* **Configuration Storage:** LittleFS filesystem (`/config.json`) parsed with [ArduinoJson](https://arduinojson.org/) v7

> **Critical Hardware Notice:**
> The ESP32-S3 N16R8 utilizes **GPIO 26 through 37** internally for Octal Flash and PSRAM bus communication. **Never connect any peripheral or pull-up to GPIOs 26-37**, as doing so will immediately trigger bootloader crash loops.

---

## 2. Directory Structure

```
Firmware/
├── platformio.ini       # PlatformIO build environments and compiler definitions
├── data/
│   └── config.json      # Base LittleFS profile filesystem template
├── include/
│   ├── config_manager.h # LittleFS profile loader and JSON parser
│   ├── display_driver.h # LovyanGFX display class and card drawing methods
│   ├── pinout.h         # GPIO pin assignments, debouncing constants, and timers
│   └── protocol.h       # Serialization and parsing of JSON host protocol
└── src/
    ├── display_driver.cpp # UI rendering routines, colors, and telemetry updates
    └── main.cpp           # Main loop, encoder state machines, key debouncing, and serial handler
```

---

## 3. Building and Flashing

### Prerequisites
Install PlatformIO Core via CLI or the VS Code extension:
```bash
# Recommended via pipx
pipx install platformio
```

### Compilation & Firmware Upload
Connect the ESP32-S3 to your PC via USB-C and run:
```bash
# Compile and upload firmware binary
pio run -t upload

# Upload initial profile configuration to LittleFS partition
pio run -t uploadfs
```

### Serial Monitoring
```bash
pio device monitor -b 115200
```

---

## 4. Hardware Recovery & Anti-Glitch Features

* **Encoder Debouncing:** Mechanical rotary contacts are filtered with software state accumulation requiring 4 transitions per detent (5% volume adjustment per tick).
* **Click Filter:** 45 ms debounce and minimum press duration filter on Knob 0 and Knob 1 prevents accidental muting while rotating.
* **Emergency Display Re-initialization:** If jumper wires experience loose contact or electrical noise, **long-press Knob 1 (> 700 ms)**. The firmware resets the ILI9341 SPI controller and redraws the UI without rebooting the microcontroller.
