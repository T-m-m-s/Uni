# Ctl_Hub

An open-source DIY Stream Deck console powered by an **ESP32-S3**, a **3.2" SPI TFT display**, **2 rotary encoders**, and **6 mechanical keyboard switches**, integrated with a lightweight, native **Linux Host daemon (`ctlhub`)**.

---

## 1. System Architecture

The project employs a decoupled architecture (**Smart Deck + Lightweight Host Bridge**):

```
┌──────────────────────────────────────────────────────────────────┐
│                      SMART DECK (ESP32-S3)                       │
│                                                                  │
│  [ LittleFS Flash Storage ]                                      │
│   └── /config.json (Profiles, Macros, Key Labels, Colors)        │
│                                                                  │
│  [ 3.2" SPI TFT Display (ILI9341, LovyanGFX) ]                   │
│   ├── Host Telemetry: CPU %, RAM %, Volume %, Active Track       │
│   ├── Profile Header & Custom Theme Colors                       │
│   └── 6 Interactive Key Labels with Realtime Press Feedback      │
│                                                                  │
│  [ Physical Controls ]                                           │
│   ├── 6 Mechanical Switches (K1 - K6)                            │
│   ├── Knob 0: Master Volume, Mute Toggle, Profile Switching      │
│   └── Knob 1: Microphone Volume, Mic Mute, Hardware Screen Reset │
└─────────────────────────────────┬────────────────────────────────┘
                                  │ USB Serial (115200 baud, JSON)
┌─────────────────────────────────┴────────────────────────────────┐
│                       LINUX HOST (ctlhub)                        │
│                                                                  │
│  [ Background Daemon & Serial Bridge ]                           │
│   ├── Telemetry Provider (PipeWire/wpctl, playerctl, psutil)     │
│   └── Command Dispatcher (Wayland / X11 shell execution)         │
│                                                                  │
│  [ IPC Socket Daemon ]                                           │
│   └── /run/user/$UID/ctlhub_$UID.sock                            │
│                                                                  │
│  [ Host Utilities & UI ]                                         │
│   ├── Unified CLI (ctlhub run/kill/reinit/status/profile)        │
│   └── Local Web Studio Configurator (http://127.0.0.1:8765)      │
└──────────────────────────────────────────────────────────────────┘
```

---

## 2. Hardware Console Layout

```
┌────────────────────────────────────────────────────────────────────────┐
│  [ LEFT BANK ]                 [ TFT DISPLAY 3.2" ]     [ RIGHT BANK ] │
│                               ┌───────────────────┐                    │
│   ┌─────────────┐             │ Active Profile    │    ┌─────────────┐ │
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

## 3. Quick Start

### A. Automatic Installation (Linux)
Run the root installer to configure the Python environment with `pipx`, set up persistent udev rules (`/dev/ctlhub`), and optionally enable the systemd user service:

```bash
git clone git@github.com:LeonardoCiscatoPajello/Ctl_Hub.git
cd Ctl_Hub
./install.sh
```

### B. Daily Usage
Once installed, the `ctlhub` command is available system-wide:

```bash
# Check hardware connection
ctlhub status

# Open local Web Studio profile configurator in browser
ctlhub gui

# Run bridge in foreground (if systemd service is disabled)
ctlhub run

# Stop background daemon or systemd service
ctlhub kill

# Re-initialize screen (in case of loose contact/glitch)
ctlhub reinit
```

---

## 4. Physical Controls & Gestures

### A. Mechanical Keys (K1 - K6)
* **Single Press:** Instantly executes the shell command or macro bound to the button in the active profile.
* **Visual Feedback:** The corresponding card on the TFT display highlights in real time upon contact.
  * **K1, K2, K3** map to the left column of the display.
  * **K4, K5, K6** map to the right column of the display.

### B. Knob 0 (Left Encoder - Master Output Audio & Profile Switch)
* **Clockwise Rotation:** Increases master volume by +5% (`wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+`).
* **Counter-Clockwise Rotation:** Decreases master volume by -5% (`wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-`).
* **Short Click:** Toggles audio output mute (`wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle`).
* **Long Press (> 0.7s):** **Switches Profile!** Cycles to the next configured profile (`General` -> `Dev & Uni` -> `Media & Stream`).

### C. Knob 1 (Right Encoder - Microphone Audio & Emergency Recovery)
* **Clockwise Rotation:** Increases microphone volume by +5% (`wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+`).
* **Counter-Clockwise Rotation:** Decreases microphone volume by -5% (`wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-`).
* **Short Click:** Toggles microphone mute (`wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle`).
* **Long Press (> 0.7s):** **Hardware Display Reset!** Resets the ILI9341 SPI controller and redraws the UI without rebooting the microcontroller.

---

## 5. Profile & Macro Customization

Profiles are defined in [`Config/esp32_config.json`](Config/esp32_config.json). You can edit the file manually or use the built-in visual editor:

```bash
ctlhub gui
```

The Web Studio opens at `http://127.0.0.1:8765`, allowing you to visually configure key labels, shell commands, theme colors, and encoder actions, and flash them directly to the Deck's LittleFS memory with one click.

Example profile snippet:
```json
{
  "id": "gaming",
  "name": "Gaming",
  "theme_color": "#E53935",
  "keys": [
    {"id": 0, "name": "Steam", "cmd": "steam"},
    {"id": 1, "name": "Discord", "cmd": "vesktop || discord"},
    {"id": 2, "name": "Terminal", "cmd": "$TERMINAL || foot || alacritty"},
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

---

## 6. Project Subsystems & Documentation

| Directory / Document | Description |
| :--- | :--- |
| **[`Hardware/`](Hardware/)** | Bill of Materials (BOM), 3D printable CAD models (`.scad`), and enclosure parameters. |
| **[`Firmware/`](Firmware/)** | PlatformIO C++ firmware, LittleFS configuration, memory settings (`qio_opi`), and build steps. |
| **[`Host/`](Host/)** | Python daemon package (`ctlhub`), systemd service setup, and IPC socket specifications. |
| **[`docs/PINOUT_AND_WIRING.md`](docs/PINOUT_AND_WIRING.md)** | Complete pin-to-pin wiring guide for ESP32-S3, ILI9341 display, encoders, and buttons. |
| **[`docs/PROTOCOL.md`](docs/PROTOCOL.md)** | Specification of the bidirectional JSON serial communication protocol. |
| **[`docs/USER_GUIDE.md`](docs/USER_GUIDE.md)** | Dedicated standalone user guide reference. |
