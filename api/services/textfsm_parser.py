import os
import textfsm
from django.conf import settings


def _template_path(device_type: str, command: str) -> str:
    safe_cmd = command.strip().lower().replace(' ', '_').replace('/', '_')
    return os.path.join(settings.BASE_DIR, 'textfsm_templates', device_type, f"{safe_cmd}.tpl")


def parse_with_textfsm(command: str, device_type: str, raw_text: str):
    tpl = _template_path(device_type, command)
    if not os.path.exists(tpl):
        return None
    with open(tpl) as fh:
        fsm = textfsm.TextFSM(fh)
        parsed = fsm.ParseText(raw_text)
        results = [dict(zip(fsm.header, row)) for row in parsed]
    return results
