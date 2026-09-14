# CtlHub - Linux Host Bridge & Daemon Package

A lightweight, native Python daemon and CLI suite for managing the **Ctl_Hub** ESP32-S3 Stream Deck console on Linux.

---

## 1. Key Capabilities

* **Minimal Memory Footprint:** Consumes less than 18 MB of RAM without persistent browser instances or heavy frameworks.
* **Low-Latency USB-Serial Bridge:** Manages bidirectional serial communication at 115200 baud with auto-reconnect.
* **UNIX Domain Socket IPC:** Embedded socket daemon at `$XDG_RUNTIME_DIR/ctlhub_$UID.sock` allows CLI commands to safely communicate with the background service without serial contention.
* **Audio & Media Integration:** Native PipeWire/WirePlumber volume adjustments and mute toggling (`wpctl`), plus media player status reporting via `playerctl`.
* **Telemetry Collector:** Periodic collection and push of CPU percentage, RAM consumption, audio levels, and active media track strings to the Deck display.
* **Embedded Web Studio Configurator (`ctlhub gui`):** Local browser-based visual profile editor running on `http://127.0.0.1:8765`.
* **Systemd User Service:** Can be run in foreground or managed as a background systemd user service (`ctlhub.service`).

---

## 2. Installation

### Automated Installation (Recommended)
From the repository root:
```bash
./install.sh
```

### Manual Installation
To install into an isolated environment using `pipx`:
```bash
# Ensure pipx is installed
pipx install --editable ./Host --force

# Install udev rules for persistent /dev/ctlhub symlink
sudo cp Host/udev/99-ctlhub.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
```

---

## 3. CLI Command Reference

| Command | Description |
| :--- | :--- |
| `ctlhub run` | Starts the host bridge daemon in the foreground. |
| `ctlhub kill` / `ctlhub stop` | Terminates active background bridge processes and stops the systemd user service. |
| `ctlhub gui` / `ctlhub web` | Opens the local Web Studio configuration interface in your browser. |
| `ctlhub reinit` / `ctlhub screen` | Sends a display reset signal to the Deck to recover from visual glitch or loose connection. |
| `ctlhub status` | Checks if a compatible serial device is detected (`/dev/ctlhub`, `/dev/ttyACM*`, `/dev/ttyUSB*`). |
| `ctlhub profile list` | Displays available profiles and highlights the currently active profile. |
| `ctlhub next` | Cycles to the next configured profile. |
| `ctlhub prev` | Cycles to the previous configured profile. |
| `ctlhub switch <target>` | Switches active profile by name, ID, or index (e.g. `ctlhub switch coding`). |
| `ctlhub sync <path.json>` | Uploads a custom profile configuration JSON to the ESP32 LittleFS flash storage. |

---

## 4. Configuration Resolution Order

The CLI and Web Studio locate the configuration file (`esp32_config.json`) dynamically:
1. `CTLHUB_CONFIG` environment variable (if defined and pointing to a file).
2. `Config/esp32_config.json` inside the working directory or repository tree.
3. User XDG configuration: `~/.config/ctlhub/esp32_config.json` (auto-seeded with default profiles if not present).

---

## 5. IPC Socket Architecture & Scripting

The bridge binds to:
```
$XDG_RUNTIME_DIR/ctlhub_$UID.sock (fallback: /tmp/ctlhub_$UID.sock)
```
Third-party utilities, shell scripts, or desktop status bars (such as Waybar, Polybar, or Rofi) can send single-line JSON commands directly to this socket:

```bash
# Example: Trigger display recovery via socket
echo '{"action": "reinit_display"}' | nc -U /run/user/$UID/ctlhub_$UID.sock

# Example: Switch profile via socket
echo '{"action": "set_profile", "target": "coding"}' | nc -U /run/user/$UID/ctlhub_$UID.sock
```
