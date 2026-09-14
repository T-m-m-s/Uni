import psutil

class TelemetryCollector:
    """Reads system performance metrics for Ctl_Hub display."""

    def __init__(self):
        # Initialize psutil cpu percent measurement
        psutil.cpu_percent(interval=None)

    def get_metrics(self) -> dict:
        """Returns current CPU and RAM percentage as integer 0-100."""
        cpu = round(psutil.cpu_percent(interval=None))
        ram = round(psutil.virtual_memory().percent)
        return {"action": "telemetry", "cpu": max(0, min(100, cpu)), "ram": max(0, min(100, ram))}
