from datetime import datetime
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework import permissions

from .services.netmiko_service import run_show_command


class HealthCheckView(APIView):
    """Simple health check endpoint for load balancers and monitoring."""
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        return Response({
            'status': 'ok',
            'timestamp': datetime.utcnow().isoformat() + 'Z',
        })


class RunShowView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        device_ip = request.data.get('device_ip')
        command = request.data.get('command')
        device_type = request.data.get('device_type')

        if not device_ip or not command or not device_type:
            return Response(
                {'error': 'device_ip, device_type, and command are required'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        username = request.data.get('username')
        password = request.data.get('password')

        if not username or not password:
            return Response(
                {'error': 'username and password are required'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        device = {'ip': device_ip, 'device_type': device_type}
        creds = {
            'username': username,
            'password': password,
            'enable_password': request.data.get('enable_password'),
            'port': int(request.data.get('port', 22)),
        }

        try:
            raw = run_show_command(device, command, creds)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        return Response({
            'device_ip': device_ip,
            'command': command,
            'output': raw,
        })
