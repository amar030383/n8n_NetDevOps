
import os
import django
from django.contrib.auth import get_user_model

# Setup Django environment
import sys
from pathlib import Path

# Add project root to sys.path
sys.path.append(str(Path(__file__).resolve().parent.parent))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'netapi.settings')
django.setup()

User = get_user_model()

def create_admin():
    username = os.environ.get('DJANGO_SUPERUSER_USERNAME', 'admin')
    email = os.environ.get('DJANGO_SUPERUSER_EMAIL', 'admin@example.com')
    password = os.environ.get('DJANGO_SUPERUSER_PASSWORD', 'admin')

    if not User.objects.filter(username=username).exists():
        print(f"Creating superuser {username}...")
        User.objects.create_superuser(username, email, password)
        print("Superuser created.")
    else:
        print(f"Superuser {username} already exists.")

if __name__ == '__main__':
    create_admin()
