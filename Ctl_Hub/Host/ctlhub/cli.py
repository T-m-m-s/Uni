import os
import sys
import time
import argparse
import subprocess
from typing import Optional

try:
    import psutil
except ImportError:
    psutil = None

if __package__ is None or __package__ == '':
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from ctlhub.bridge import SerialBridge
    from ctlhub.config import ConfigManager
    from ctlhub.web_server import run_server
else:
    from .bridge import SerialBridge
    from .config import ConfigManager
    from .web_server import run_server

def cmd_run(args):
    bridge = SerialBridge(port=args.port, baud=args.baud, telemetry_interval=args.interval)
    bridge.run()

def cmd_sync(args):
    config_path = args.config
    print(f"\033[94m[SYNC]\033[0m Loading configuration from: {config_path}")
    try:
        cfg = ConfigManager.load_config(config_path)
    except Exception as e:
        print(f"\033[91m[ERROR]\033[0m Failed to parse config: {e}")
        sys.exit(1)

    bridge = SerialBridge(port=args.port, baud=args.baud)
    if not bridge.connect():
        print(f"\033[91m[ERROR]\033[0m Could not connect to Ctl_Hub. Ensure USB cable is plugged in.")
        sys.exit(1)

    payload = ConfigManager.format_save_payload(cfg)
    print("\033[94m[SYNC]\033[0m Uploading new profile configuration to ESP32 LittleFS...")
    bridge.send_line(payload)
    time.sleep(1.0)
    print("\033[92m[SYNC COMPLETE]\033[0m Configuration uploaded!")
    if bridge.ser:
        bridge.ser.close()

def cmd_status(args):
    port = SerialBridge.find_port()
    if port:
        print(f"\033[92m[FOUND]\033[0m Ctl_Hub detected on: \033[1m{port}\033[0m")
    else:
        print("\033[93m[NOT DETECTED]\033[0m No Ctl_Hub serial device found (/dev/ctlhub, /dev/ttyACM*, /dev/ttyUSB*)")

def cmd_reinit(args):
    print("\033[94m[SCREEN]\033[0m Invio segnale di re-inizializzazione display all'ESP32...")
    ok, medium = SerialBridge.send_command({"action": "reinit_display"}, port=args.port, baud=args.baud)
    if ok:
        print(f"\033[92m[SCREEN OK]\033[0m Comando inviato con successo tramite \033[1m{medium}\033[0m!")
    else:
        print(f"\033[91m[ERROR]\033[0m Impossibile comunicare con Ctl_Hub: {medium}")

def cmd_kill(args):
    killed_any = False

    # 1. Stop systemd user service if running
    try:
        res = subprocess.run(
            ["systemctl", "--user", "is-active", "--quiet", "ctlhub.service"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        if res.returncode == 0:
            subprocess.run(["systemctl", "--user", "stop", "ctlhub.service"], check=True)
            print("\033[92m[STOP]\033[0m Servizio systemd ctlhub.service arrestato.")
            killed_any = True
    except Exception:
        pass

    # 2. Terminate background processes
    curr_pid = os.getpid()
    if psutil:
        for proc in psutil.process_iter(["pid", "name", "cmdline"]):
            if proc.info["pid"] == curr_pid:
                continue
            cmdline = proc.info.get("cmdline") or []
            cmd_str = " ".join(cmdline)
            if ("ctlhub" in cmd_str and "run" in cmd_str) or ("ctlhub.cli" in cmd_str and "kill" not in cmd_str):
                try:
                    proc.terminate()
                    proc.wait(timeout=1.5)
                except (psutil.TimeoutExpired, psutil.NoSuchProcess):
                    try:
                        proc.kill()
                    except Exception:
                        pass
                print(f"\033[92m[KILL]\033[0m Processo Ctl_Hub (PID {proc.info['pid']}) terminato.")
                killed_any = True
    else:
        try:
            res = subprocess.run(["pkill", "-f", "ctlhub run"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if res.returncode == 0:
                print("\033[92m[KILL]\033[0m Processi ctlhub terminati.")
                killed_any = True
        except Exception:
            pass

    if not killed_any:
        print("\033[93m[INFO]\033[0m Nessun processo o servizio Ctl_Hub attivo trovato.")

def cmd_gui(args):
    run_server(port=args.port_http, open_browser=not args.no_browser)

def cmd_profile_list(args):
    try:
        profiles, active = ConfigManager.list_profiles()
    except Exception as e:
        print(f"\033[91m[ERROR]\033[0m Could not read profiles: {e}")
        return

    cfg_path = ConfigManager.get_default_config_path()
    print(f"\033[1mCtl_Hub Profiles\033[0m (\033[90m{cfg_path}\033[0m):")
    for idx, p in enumerate(profiles):
        p_id = p.get("id", f"prof_{idx}")
        p_name = p.get("name", "Unnamed")
        color = p.get("theme_color", "#fff")
        is_active = (p_id == active or idx == 0 and not active)
        marker = "\033[92m*\033[0m" if is_active else " "
        active_tag = " \033[92m[ACTIVE]\033[0m" if is_active else ""
        print(f"  {marker} [{idx}] \033[1m{p_id:<12}\033[0m - {p_name:<20} ({color}){active_tag}")

def _apply_profile_switch(target_prof: dict, idx: int, port: Optional[str] = None, baud: int = 115200):
    p_id = target_prof.get("id", "")
    p_name = target_prof.get("name", "")

    # 1. Update active_profile in esp32_config.json
    try:
        cfg = ConfigManager.load_config()
        cfg["active_profile"] = p_id
        ConfigManager.save_config(cfg)
    except Exception as e:
        print(f"\033[93m[CONFIG WARN]\033[0m Could not update local json: {e}")

    # 2. Dispatch event to hardware
    cmd_payload = {"action": "set_profile", "target": p_id}
    ok, medium = SerialBridge.send_command(cmd_payload, port=port, baud=baud)

    status_tag = f"(\033[94m{medium}\033[0m)" if ok else "(\033[93mhardware non connesso, aggiornato solo file locale\033[0m)"
    print(f"\033[95m[PROFILE]\033[0m Switched to \033[1m[{idx}] {p_name}\033[0m ({p_id}) {status_tag}")

def cmd_profile_switch(args):
    target = args.target
    prof = ConfigManager.resolve_target(target)
    if not prof:
        print(f"\033[91m[ERROR]\033[0m Profilo '{target}' non trovato. Esegui 'ctlhub profile list' per vedere i profili disponibili.")
        sys.exit(1)

    profiles, _ = ConfigManager.list_profiles()
    idx = profiles.index(prof)
    _apply_profile_switch(prof, idx, port=args.port, baud=args.baud)

def cmd_profile_next(args):
    profiles, active = ConfigManager.list_profiles()
    if not profiles:
        print("\033[91m[ERROR]\033[0m Nessun profilo configurato.")
        return

    curr_idx = 0
    for i, p in enumerate(profiles):
        if p.get("id") == active:
            curr_idx = i
            break

    next_idx = (curr_idx + 1) % len(profiles)
    _apply_profile_switch(profiles[next_idx], next_idx, port=args.port, baud=args.baud)

def cmd_profile_prev(args):
    profiles, active = ConfigManager.list_profiles()
    if not profiles:
        print("\033[91m[ERROR]\033[0m Nessun profilo configurato.")
        return

    curr_idx = 0
    for i, p in enumerate(profiles):
        if p.get("id") == active:
            curr_idx = i
            break

    prev_idx = (curr_idx - 1 + len(profiles)) % len(profiles)
    _apply_profile_switch(profiles[prev_idx], prev_idx, port=args.port, baud=args.baud)

def main():
    parser = argparse.ArgumentParser(
        prog="ctlhub",
        description="Ctl_Hub ESP32-S3 Stream Deck Linux Host Utility"
    )
    parser.add_argument("--port", "-p", help="Explicit serial port (default: auto-detect)", default=None)
    parser.add_argument("--baud", "-b", help="Baud rate (default: 115200)", type=int, default=115200)

    subparsers = parser.add_subparsers(dest="command", help="Available subcommands")

    # Command: run (default)
    parser_run = subparsers.add_parser("run", help="Run the background bridge daemon")
    parser_run.add_argument("--interval", "-i", help="Telemetry interval in seconds", type=float, default=2.0)
    parser_run.set_defaults(func=cmd_run)

    # Command: gui / web
    parser_gui = subparsers.add_parser("gui", aliases=["web"], help="Open local Web GUI configurator in browser")
    parser_gui.add_argument("--port-http", help="HTTP Port (default: 8765)", type=int, default=8765)
    parser_gui.add_argument("--no-browser", help="Do not auto-open browser", action="store_true")
    parser_gui.set_defaults(func=cmd_gui)

    # Command: sync
    parser_sync = subparsers.add_parser("sync", help="Upload a new esp32_config.json to the Deck")
    parser_sync.add_argument("config", help="Path to config.json file (e.g. Config/esp32_config.json)")
    parser_sync.set_defaults(func=cmd_sync)

    # Command: status
    parser_status = subparsers.add_parser("status", help="Check if Ctl_Hub is connected")
    parser_status.set_defaults(func=cmd_status)

    # Command: profile
    parser_prof = subparsers.add_parser("profile", help="Manage and switch deck user profiles")
    prof_sub = parser_prof.add_subparsers(dest="profile_action", help="Profile action")

    prof_list = prof_sub.add_parser("list", aliases=["ls"], help="List all available profiles")
    prof_list.set_defaults(func=cmd_profile_list)

    prof_switch = prof_sub.add_parser("switch", aliases=["set"], help="Switch to profile by index, id or name")
    prof_switch.add_argument("target", help="Profile ID, name, or numeric index")
    prof_switch.set_defaults(func=cmd_profile_switch)

    prof_next = prof_sub.add_parser("next", help="Cycle to next profile")
    prof_next.set_defaults(func=cmd_profile_next)

    prof_prev = prof_sub.add_parser("prev", help="Cycle to previous profile")
    prof_prev.set_defaults(func=cmd_profile_prev)

    # Top-level direct shortcuts: next, prev, switch
    p_next_sc = subparsers.add_parser("next", help="Shortcut: cycle to next profile")
    p_next_sc.set_defaults(func=cmd_profile_next)

    p_prev_sc = subparsers.add_parser("prev", help="Shortcut: cycle to previous profile")
    p_prev_sc.set_defaults(func=cmd_profile_prev)

    p_switch_sc = subparsers.add_parser("switch", help="Shortcut: switch to profile")
    p_switch_sc.add_argument("target", help="Profile ID, name, or numeric index")
    p_switch_sc.set_defaults(func=cmd_profile_switch)

    # Reinit display shortcut
    p_reinit_sc = subparsers.add_parser("reinit", aliases=["screen", "recover"], help="Re-inizializza il display e ridisegna la UI (utile dopo un falso contatto)")
    p_reinit_sc.set_defaults(func=cmd_reinit)

    # Kill daemon shortcut
    p_kill_sc = subparsers.add_parser("kill", aliases=["stop"], help="Arresta il processo ctlhub o il servizio systemd in esecuzione")
    p_kill_sc.set_defaults(func=cmd_kill)

    args = parser.parse_args()
    if not args.command:
        cmd_run(args)
    else:
        if args.command == "profile" and not getattr(args, "profile_action", None):
            cmd_profile_list(args)
        else:
            args.func(args)

if __name__ == "__main__":
    main()
