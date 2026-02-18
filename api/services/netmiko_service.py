from netmiko import ConnectHandler


def run_show_command(device: dict, command: str, creds: dict) -> str:
    conn_params = {
        'device_type': device.get('device_type'),
        'host': device.get('ip'),
        'username': creds.get('username'),
        'password': creds.get('password'),
        'port': creds.get('port', 22),
        'fast_cli': False,
    }
    if creds.get('enable_password'):
        conn_params['secret'] = creds.get('enable_password')
    net_connect = ConnectHandler(**conn_params)
    try:
        if creds.get('enable_password'):
            try:
                net_connect.enable()
            except Exception:
                pass
        output = net_connect.send_command(command,use_textfsm=True)
    finally:
        try:
            net_connect.disconnect()
        except Exception:
            pass
    return output
