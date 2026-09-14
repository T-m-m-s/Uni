import os
import json
from typing import Dict, Any, Optional, List, Tuple

from pathlib import Path

def get_xdg_config_path() -> str:
    xdg_config = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    return os.path.join(xdg_config, "ctlhub", "esp32_config.json")

def find_repo_config_path() -> Optional[str]:
    """Search for esp32_config.json in parent directories or working directory."""
    # 1. Current working directory
    cwd = Path.cwd()
    for cand in [cwd / "Config" / "esp32_config.json", cwd / "Software" / "esp32_config.json", cwd / "esp32_config.json"]:
        if cand.is_file():
            return str(cand.resolve())

    # 2. Walk up parent directories from this file
    cur = Path(__file__).resolve().parent
    for _ in range(6):
        cand1 = cur / "Config" / "esp32_config.json"
        if cand1.is_file():
            return str(cand1)
        cand2 = cur / "Software" / "esp32_config.json"
        if cand2.is_file():
            return str(cand2)
        cand3 = cur / "esp32_config.json"
        if cand3.is_file():
            return str(cand3)
        if cur.parent == cur:
            break
        cur = cur.parent

    return None

def get_default_config_path() -> str:
    """
    Resolves the configuration file in priority order:
    1. CTLHUB_CONFIG environment variable (if set and points to an existing file)
    2. Repository / workspace esp32_config.json
    3. User XDG config path (~/.config/ctlhub/esp32_config.json)
    """
    env_cfg = os.environ.get("CTLHUB_CONFIG")
    if env_cfg and os.path.isfile(env_cfg):
        return os.path.abspath(env_cfg)

    repo_cfg = find_repo_config_path()
    if repo_cfg:
        return repo_cfg

    return get_xdg_config_path()

class ConfigManager:
    """Manages Ctl_Hub profile configurations and LittleFS syncing."""

    @staticmethod
    def get_default_config_path() -> str:
        return get_default_config_path()

    @staticmethod
    def get_fallback_default_config() -> Dict[str, Any]:
        return {
            "version": 1,
            "active_profile": "general",
            "profiles": [
                {
                    "id": "general",
                    "name": "Generale",
                    "theme_color": "#1976D2",
                    "keys": [
                        {"id": 0, "name": "Browser", "cmd": "xdg-open https://google.com || sensible-browser"},
                        {"id": 1, "name": "Chat", "cmd": "discord || vesktop"},
                        {"id": 2, "name": "Terminale", "cmd": "$TERMINAL || x-terminal-emulator || foot || alacritty || kitty || xterm"},
                        {"id": 3, "name": "Mute Audio", "cmd": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || pactl set-sink-mute @DEFAULT_SINK@ toggle"},
                        {"id": 4, "name": "Mute Mic", "cmd": "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle || pactl set-source-mute @DEFAULT_SOURCE@ toggle"},
                        {"id": 5, "name": "Screenshot", "cmd": "grim -g \"$(slurp)\" - | wl-copy || flameshot gui || spectacle -r"}
                    ],
                    "knobs": {
                        "knob_0": {"rotate_action": "volume_out", "click_cmd": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || pactl set-sink-mute @DEFAULT_SINK@ toggle"},
                        "knob_1": {"rotate_action": "volume_mic", "click_cmd": "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle || pactl set-source-mute @DEFAULT_SOURCE@ toggle"}
                    }
                }
            ]
        }

    @staticmethod
    def load_config(file_path: Optional[str] = None) -> Dict[str, Any]:
        """Loads and validates a config JSON file."""
        path = file_path or get_default_config_path()
        if not os.path.isfile(path):
            # If path is XDG user config and does not exist yet, auto-create it with default template
            if os.path.abspath(path) == os.path.abspath(get_xdg_config_path()):
                default_cfg = ConfigManager.get_fallback_default_config()
                ConfigManager.save_config(default_cfg, path)
                return default_cfg
            raise FileNotFoundError(f"Configuration file not found: {path}")

        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)

        if "profiles" not in data or not isinstance(data["profiles"], list):
            raise ValueError("Invalid config format: missing 'profiles' list")

        return data

    @staticmethod
    def save_config(data: Dict[str, Any], file_path: Optional[str] = None):
        path = file_path or get_default_config_path()
        os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            f.write("\n")

    @staticmethod
    def format_save_payload(data: Dict[str, Any]) -> str:
        """Encapsulates config in save_config action for ESP32 serial protocol."""
        return json.dumps({"action": "save_config", "config": data}) + "\n"

    @classmethod
    def list_profiles(cls, file_path: Optional[str] = None) -> Tuple[List[Dict[str, Any]], str]:
        cfg = cls.load_config(file_path)
        active = cfg.get("active_profile", "general")
        return cfg.get("profiles", []), active

    @classmethod
    def resolve_target(cls, target: str, file_path: Optional[str] = None) -> Optional[Dict[str, Any]]:
        profiles, _ = cls.list_profiles(file_path)
        # Check by numeric index
        if target.isdigit():
            idx = int(target)
            if 0 <= idx < len(profiles):
                return profiles[idx]

        # Check by id or name
        target_lower = target.lower()
        for p in profiles:
            p_id = str(p.get("id", "")).lower()
            p_name = str(p.get("name", "")).lower()
            if target_lower in (p_id, p_name):
                return p
        return None
