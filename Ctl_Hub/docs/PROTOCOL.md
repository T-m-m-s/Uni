# Ctl_Hub - Serial Communication Protocol Specification

This document defines the newline-delimited JSON protocol exchanged over the USB serial interface (115200 baud, 8N1) between the **Ctl_Hub ESP32-S3 Deck** and the **Linux Host Bridge (`ctlhub`)**.

---

## 1. Physical & Framing Layer

- **Physical Media:** USB-CDC / UART serial interface (`/dev/ctlhub`, `/dev/ttyACM*`, `/dev/ttyUSB*`).
- **Baud Rate:** 115200 baud.
- **Framing:** Plain ASCII/UTF-8 JSON objects terminated by a single newline (`\n`).
- **Flow Control:** None (software request-response / asynchronous event push).

---

## 2. Deck to Host Messages (Events)

These JSON payloads are generated asynchronously by the ESP32 firmware when user interactions occur.

### A. Key Press Event (`exec`)
Triggered when one of the 6 mechanical keys is pressed down.

```json
{
  "event": "exec",
  "btn_id": 0,
  "cmd": "xdg-open https://google.com || sensible-browser"
}
```

| Field | Type | Description |
| :--- | :--- | :--- |
| `event` | string | Constant: `"exec"` |
| `btn_id` | integer | Index of the pressed key (`0` to `5`) |
| `cmd` | string | Shell command string retrieved from the active LittleFS profile |

---

### B. Rotary Encoder Turn (`knob`)
Triggered when an encoder reaches a physical detent (4 quadrature transitions).

```json
{
  "event": "knob",
  "id": 0,
  "delta": 1
}
```

| Field | Type | Description |
| :--- | :--- | :--- |
| `event` | string | Constant: `"knob"` |
| `id` | integer | `0` for Left Knob (Master Volume), `1` for Right Knob (Microphone) |
| `delta` | integer | `+1` for Clockwise (+5%), `-1` for Counter-Clockwise (-5%) |

---

### C. Rotary Encoder Switch Click (`knob_btn`)
Triggered when the integrated push button of an encoder is pressed.

```json
{
  "event": "knob_btn",
  "id": 0
}
```

| Field | Type | Description |
| :--- | :--- | :--- |
| `event` | string | Constant: `"knob_btn"` |
| `id` | integer | `0` for Left Knob (Mute toggle), `1` for Right Knob (Mic mute toggle) |

---

### D. Profile Changed Event (`profile_changed`)
Triggered when the profile is changed directly on the Deck (via Knob 0 long-press > 0.7s) or via command.

```json
{
  "event": "profile_changed",
  "active_profile": "coding"
}
```

---

### E. Diagnostic Firmware Log (`log`)
Informational messages output by the firmware during initialization or debugging.

```json
{
  "log": "Ctl_Hub ESP32-S3 Initialized. Active profile: general"
}
```

---

## 3. Host to Deck Messages (Actions)

These JSON payloads are sent by the host daemon or CLI utilities to control the Deck hardware.

### A. Telemetry Update (`telemetry`)
Sent periodically (every 2.0s by default) by the background host daemon.

```json
{
  "action": "telemetry",
  "cpu": 14,
  "ram": 42,
  "vol": 65,
  "vol_mute": false,
  "mic": 80,
  "mic_mute": false,
  "track": "Song Title - Artist Name"
}
```

| Field | Type | Description |
| :--- | :--- | :--- |
| `action` | string | Constant: `"telemetry"` |
| `cpu` | integer | Total CPU utilization percentage (`0` to `100`) |
| `ram` | integer | System memory utilization percentage (`0` to `100`) |
| `vol` | integer | Master audio sink volume (`0` to `100`) |
| `vol_mute` | boolean | Audio sink mute state |
| `mic` | integer | Audio source (mic) volume (`0` to `100`) |
| `mic_mute` | boolean | Audio source mute state |
| `track` | string | Currently playing media track string (via `playerctl`) |

---

### B. Display Reinitialization (`reinit_display`)
Forces the firmware to reset the SPI TFT controller and redraw the interface from scratch.

```json
{
  "action": "reinit_display"
}
```

---

### C. Remote Profile Switch (`set_profile`)
Switches the active profile stored on the Deck.

```json
{
  "action": "set_profile",
  "target": "gaming"
}
```

---

### D. Upload Full Configuration (`save_config`)
Uploads the complete profile JSON to the Deck, saving it into LittleFS (`/config.json`).

```json
{
  "action": "save_config",
  "config": {
    "version": 1,
    "active_profile": "general",
    "profiles": [ ... ]
  }
}
```
