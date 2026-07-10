import os
import sys
import django

# Set up Django environment
sys.path.append(r"c:\Users\ACER\my_pro\itqan_academy_backend")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "itqan_server.settings")
django.setup()

from rest_framework.test import APIClient
from django.contrib.auth.models import User

client = APIClient()
user = User.objects.filter(is_superuser=True).first()
if not user:
    # Create a temporary user for testing
    user = User.objects.create_superuser('test_admin', 'admin@test.com', 'password123')

client.force_authenticate(user=user)

print("--- Requesting GET /api/v1/circles/ ---")
try:
    response = client.get('/api/v1/circles/')
    print("Status code:", response.status_code)
    if response.status_code != 200:
        print("Response Content:")
        print(response.content.decode('utf-8')[:3000])
except Exception as e:
    import traceback
    traceback.print_exc()

print("\n--- Requesting GET /api/v1/students/ ---")
try:
    response = client.get('/api/v1/students/')
    print("Status code:", response.status_code)
    if response.status_code != 200:
        print("Response Content:")
        print(response.content.decode('utf-8')[:3000])
except Exception as e:
    import traceback
    traceback.print_exc()
