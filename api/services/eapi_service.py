"""Arista eAPI client - HTTP alternative to SSH for EOS devices."""

import pyeapi


def run_show_via_eapi(device_ip: str, command: str, username: str, password: str, port: int = 80) -> str:
    """Run show command via Arista eAPI (HTTP/HTTPS). Returns raw text output."""
    transport = 'https' if port == 443 else 'http'
    conn = pyeapi.connect(
        host=device_ip,
        username=username,
        password=password,
        port=port,
        transport=transport,
    )
    node = pyeapi.client.Node(conn)
    # Request text encoding for compatibility with Netmiko/textfsm output
    result = node.enable({'cmd': command, 'encoding': 'text'})
    if not result:
        return ''
    output = result[0]
    if isinstance(output, dict) and 'result' in output:
        return str(output['result']).strip()
    return str(output).strip()
