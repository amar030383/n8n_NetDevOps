import csv
from typing import Dict


def load_devices(path: str) -> Dict[str, dict]:
    devices = {}
    try:
        with open(path, newline='') as f:
            reader = csv.DictReader(f)
            for row in reader:
                name = row.get('device_name')
                ip = row.get('ip_address') or row.get('ip')
                dtype = row.get('device_type')
                if name and ip and dtype:
                    devices[name] = {'ip': ip, 'device_type': dtype}
    except FileNotFoundError:
        pass
    return devices
