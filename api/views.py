import os
from datetime import datetime
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from .services.csv_loader import load_devices
from .services.env_loader import get_credentials
from .services.netmiko_service import run_show_command
from .services.textfsm_parser import parse_with_textfsm


class HealthCheckView(APIView):
    """Simple health check endpoint for load balancers and monitoring."""

    def get(self, request):
        return Response({
            'status': 'ok',
            'timestamp': datetime.utcnow().isoformat() + 'Z',
        })


class RunShowView(APIView):
    def post(self, request):
        device_ip = request.data.get('device_ip')
        command = request.data.get('command')
        device_type = request.data.get('device_type')

        if not device_ip or not command:
            return Response({'error': 'device_ip and command required'}, status=status.HTTP_400_BAD_REQUEST)

        # Look up device_type from devices.csv if not provided
        if not device_type:
            devices_csv = os.path.join(settings.BASE_DIR, 'devices.csv')
            devices = load_devices(devices_csv)
            device = next((d for d in devices.values() if d.get('ip') == device_ip), None)
            if device:
                device_type = device.get('device_type')
            else:
                return Response({'error': 'device_type required when device_ip not in devices.csv'}, status=status.HTTP_400_BAD_REQUEST)

        device = {'ip': device_ip, 'device_type': device_type}

        creds = get_credentials()
        try:
            raw = run_show_command(device, command, creds)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        parsed = parse_with_textfsm(command, device_type, raw)

        return Response({
            'device_ip': device_ip,
            'command': command,
            'raw_output': raw,
            'parsed_output': parsed,
        })
