import os


def get_credentials():
    return {
        'username': os.environ.get('NET_DEVICE_USERNAME'),
        'password': os.environ.get('NET_DEVICE_PASSWORD'),
        'enable_password': os.environ.get('NET_DEVICE_ENABLE_PASSWORD'),
        'port': int(os.environ.get('NET_DEVICE_PORT', '22')),
    }
