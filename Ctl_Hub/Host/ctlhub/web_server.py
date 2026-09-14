import os
import json
import time
import socket
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from typing import Optional

from .bridge import SerialBridge
from .config import ConfigManager

STATIC_DIR = os.path.join(os.path.dirname(__file__), "static")

MIME_TYPES = {
    ".html": "text/html; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".js": "application/javascript; charset=utf-8",
    ".json": "application/json; charset=utf-8",
    ".svg": "image/svg+xml"
}

class CtlHubHTTPHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        # Clean custom request log
        pass

    def _send_json(self, data: dict, code: int = 200):
        body = json.dumps(data).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        req_path = self.path.split("?")[0]
        if req_path in ("/", "/index.html"):
            self._serve_static_file("index.html")
        elif req_path in ("/style.css", "/app.js"):
            filename = req_path.lstrip("/")
            self._serve_static_file(filename)
        elif req_path == "/api/config":
            try:
                data = ConfigManager.load_config()
                self._send_json(data)
            except Exception as e:
                self._send_json({"error": str(e)}, 500)
        elif req_path == "/api/status":
            port = SerialBridge.find_port()
            self._send_json({"connected": port is not None, "port": port})
        else:
            self.send_response(404)
            self.end_headers()

    def _serve_static_file(self, filename: str):
        filepath = os.path.join(STATIC_DIR, filename)
        if not os.path.isfile(filepath):
            self.send_response(404)
            self.end_headers()
            return

        ext = os.path.splitext(filename)[1].lower()
        content_type = MIME_TYPES.get(ext, "application/octet-stream")

        with open(filepath, "rb") as f:
            content = f.read()

        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)

    def do_POST(self):
        content_len = int(self.headers.get("Content-Length", 0))
        post_body = self.rfile.read(content_len).decode("utf-8")

        if self.path == "/api/config":
            try:
                new_data = json.loads(post_body)
                ConfigManager.save_config(new_data)
                self._send_json({"success": True})
            except Exception as e:
                self._send_json({"success": False, "error": str(e)}, 500)

        elif self.path == "/api/sync":
            try:
                data = ConfigManager.load_config()
                payload = ConfigManager.format_save_payload(data)

                bridge = SerialBridge()
                if not bridge.connect():
                    self._send_json({"success": False, "error": "Dispositivo seriale ESP32 non rilevato"}, 400)
                    return

                bridge.send_line(payload)
                time.sleep(0.5)
                if bridge.ser:
                    bridge.ser.close()

                self._send_json({"success": True})
            except Exception as e:
                self._send_json({"success": False, "error": str(e)}, 500)
        else:
            self.send_response(404)
            self.end_headers()

def run_server(port: int = 8765, open_browser: bool = True):
    config_path = ConfigManager.get_default_config_path()
    server = HTTPServer(("127.0.0.1", port), CtlHubHTTPHandler)
    url = f"http://127.0.0.1:{port}"
    print(f"\033[92m[CTL_HUB STUDIO]\033[0m Local Web GUI running on \033[1m{url}\033[0m")
    print(f"Loaded config: \033[94m{config_path}\033[0m")

    if open_browser:
        try:
            webbrowser.open(url)
        except Exception:
            pass

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping web GUI...")
    finally:
        server.server_close()
