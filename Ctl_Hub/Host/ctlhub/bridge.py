import os
import sys
import glob
import time
import json
import socket
import threading
import subprocess
from typing import Optional, Tuple

try:
    import serial
except ImportError:
    serial = None

from .telemetry import TelemetryCollector

def get_socket_path() -> str:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
    return os.path.join(runtime_dir, f"ctlhub_{os.getuid()}.sock")

class SerialBridge:
    """Serial communication bridge connecting Linux host to Ctl_Hub Deck."""

    DEFAULT_PORTS = ["/dev/ctlhub", "/dev/ttyACM0", "/dev/ttyACM1", "/dev/ttyUSB0"]

    def __init__(self, port: Optional[str] = None, baud: int = 115200, telemetry_interval: float = 2.0):
        self.port = port
        self.baud = baud
        self.telemetry_interval = telemetry_interval
        self.ser: Optional[serial.Serial] = None
        self.running = False
        self.telemetry = TelemetryCollector()

    @classmethod
    def find_port(cls) -> Optional[str]:
        if os.path.exists("/dev/ctlhub"):
            return "/dev/ctlhub"
        acm = sorted(glob.glob("/dev/ttyACM*"))
        if acm:
            return acm[0]
        usb = sorted(glob.glob("/dev/ttyUSB*"))
        if usb:
            return usb[0]
        return None

    def connect(self) -> bool:
        if serial is None:
            print("\033[91m[ERROR]\033[0m 'pyserial' non è installato. Esegui: pip install pyserial")
            return False
        target_port = self.port or self.find_port()
        if not target_port:
            return False
        try:
            self.ser = serial.Serial(target_port, self.baud, timeout=1.0)
            self.port = target_port
            time.sleep(0.5)
            return True
        except Exception as err:
            print(f"\033[91m[ERROR]\033[0m Could not open {target_port}: {err}")
            return False

    def send_line(self, line: str):
        if self.ser and self.ser.is_open:
            if not line.endswith("\n"):
                line += "\n"
            self.ser.write(line.encode("utf-8"))

    def _telemetry_loop(self, stop_event: threading.Event):
        while not stop_event.is_set():
            if self.ser and self.ser.is_open:
                try:
                    metrics = self.telemetry.get_metrics()
                    self.send_line(json.dumps(metrics))
                except Exception:
                    pass
            stop_event.wait(self.telemetry_interval)

    def _ipc_server_loop(self, stop_event: threading.Event):
        sock_path = get_socket_path()
        try:
            if os.path.exists(sock_path):
                os.unlink(sock_path)
        except OSError:
            pass

        try:
            srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            srv.bind(sock_path)
            srv.listen(5)
            srv.settimeout(0.5)
        except Exception as e:
            print(f"\033[93m[IPC WARN]\033[0m Could not bind IPC socket: {e}")
            return

        while not stop_event.is_set():
            try:
                conn, _ = srv.accept()
            except socket.timeout:
                continue
            except Exception:
                break

            try:
                data = conn.recv(1024).decode("utf-8", errors="replace").strip()
                if data:
                    self.send_line(data)
                    conn.sendall(b'{"status":"ok"}\n')
            except Exception:
                pass
            finally:
                conn.close()

        srv.close()
        try:
            if os.path.exists(sock_path):
                os.unlink(sock_path)
        except OSError:
            pass

    @classmethod
    def send_command(cls, payload: dict, port: Optional[str] = None, baud: int = 115200) -> Tuple[bool, str]:
        """Send command to ESP32 via background daemon socket or direct serial."""
        sock_path = get_socket_path()
        line = json.dumps(payload) + "\n"

        # 1. Try local IPC socket (active bridge daemon)
        if os.path.exists(sock_path):
            try:
                s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                s.settimeout(1.0)
                s.connect(sock_path)
                s.sendall(line.encode("utf-8"))
                s.recv(1024)
                s.close()
                return True, "bridge daemon"
            except Exception:
                pass

        # 2. Try direct serial port access
        bridge = cls(port=port, baud=baud)
        if not bridge.connect():
            return False, "Nessun dispositivo ESP32 rilevato"

        bridge.send_line(line)
        time.sleep(0.15)
        if bridge.ser:
            bridge.ser.close()
        return True, "porta seriale diretta"

    def execute_command(self, cmd: str):
        if not cmd or not cmd.strip():
            return
        print(f"\033[94m[EXEC]\033[0m {cmd}")
        env = os.environ.copy()
        env.setdefault("WAYLAND_DISPLAY", "wayland-1")
        env.setdefault("DISPLAY", ":0")
        env.setdefault("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
        try:
            subprocess.Popen(cmd, shell=True, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception as e:
            print(f"\033[91m[EXEC ERROR]\033[0m {e}")

    def handle_knob(self, knob_id: int, delta: int):
        param = "5%+" if delta > 0 else "5%-"
        if knob_id == 0:
            print(f"\033[93m[KNOB 0 - VOL]\033[0m Master Audio {param}")
            subprocess.run(f"wpctl set-volume @DEFAULT_AUDIO_SINK@ {param} || pactl set-sink-volume @DEFAULT_SINK@ {param}", shell=True)
        elif knob_id == 1:
            print(f"\033[93m[KNOB 1 - MIC]\033[0m Mic Volume {param}")
            subprocess.run(f"wpctl set-volume @DEFAULT_AUDIO_SOURCE@ {param} || pactl set-source-volume @DEFAULT_SOURCE@ {param}", shell=True)

    def handle_knob_btn(self, knob_id: int):
        if knob_id == 0:
            print("\033[93m[KNOB 0 - CLICK]\033[0m Toggle Mute Sink")
            subprocess.run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || pactl set-sink-mute @DEFAULT_SINK@ toggle", shell=True)
        elif knob_id == 1:
            print("\033[93m[KNOB 1 - CLICK]\033[0m Toggle Mute Mic")
            subprocess.run("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle || pactl set-source-mute @DEFAULT_SOURCE@ toggle", shell=True)

    def run(self):
        self.running = True
        while self.running:
            if not self.connect():
                print("\033[93m[WAITING]\033[0m Ctl_Hub not found. Retrying in 2 seconds...")
                try:
                    time.sleep(2.0)
                except KeyboardInterrupt:
                    print("\nShutting down bridge...")
                    return
                continue

            print(f"\033[92m[CONNECTED]\033[0m Ctl_Hub active on \033[1m{self.port}\033[0m (Baud: {self.baud})")
            # Auto-reinit display immediately so screen wakes up on bridge launch/reconnect
            self.send_line(json.dumps({"action": "reinit_display"}))
            print("Ready. Listening for hardware deck events...")

            stop_threads = threading.Event()
            telem_thread = threading.Thread(target=self._telemetry_loop, args=(stop_threads,), daemon=True)
            ipc_thread = threading.Thread(target=self._ipc_server_loop, args=(stop_threads,), daemon=True)

            telem_thread.start()
            ipc_thread.start()

            try:
                while self.running:
                    try:
                        line = self.ser.readline().decode("utf-8", errors="replace").strip()
                    except Exception as err:
                        print(f"\033[91m[DISCONNECTED]\033[0m Device disconnected: {err}")
                        break

                    if not line:
                        continue

                    try:
                        data = json.loads(line)
                    except json.JSONDecodeError:
                        print(f"\033[90m[RAW]\033[0m {line}")
                        continue

                    event = data.get("event")

                    if event == "exec":
                        btn_id = data.get("btn_id", -1)
                        cmd = data.get("cmd", "")
                        print(f"\033[92m[KEY]\033[0m Button K{btn_id + 1} pressed")
                        self.execute_command(cmd)

                    elif event == "knob":
                        self.handle_knob(data.get("id", 0), data.get("delta", 0))

                    elif event == "knob_btn":
                        self.handle_knob_btn(data.get("id", 0))

                    elif event == "profile_changed":
                        prof = data.get("active_profile", "")
                        print(f"\033[95m[PROFILE]\033[0m Deck switched to: \033[1m{prof}\033[0m")

                    elif data.get("status") == "saved_ok":
                        print("\033[92m[SYNC OK]\033[0m Configuration successfully saved to ESP32 LittleFS!")

                    elif "log" in data:
                        print(f"\033[96m[ESP32 LOG]\033[0m {data['log']}")

            except KeyboardInterrupt:
                print("\nShutting down bridge...")
                self.running = False
            finally:
                stop_threads.set()
                if self.ser:
                    try:
                        self.ser.close()
                    except Exception:
                        pass
                    self.ser = None

            if self.running:
                print("\033[93m[RETRY]\033[0m Attempting automatic reconnection in 2s...")
                try:
                    time.sleep(2.0)
                except KeyboardInterrupt:
                    print("\nShutting down bridge...")
                    self.running = False

        print("Bridge stopped.")
