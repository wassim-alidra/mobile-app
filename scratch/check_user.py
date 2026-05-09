import os
import sys
import django

# Set up Django environment
sys.path.append(r'c:\Users\ASUS\Documents\Agrigov\team-work\backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'agri_gov_market.settings')
django.setup()

from django.contrib.auth import get_user_model
User = get_user_model()

try:
    user = User.objects.get(username='Transporter2')
    print(f"User: {user.username}")
    print(f"Role: {user.role}")
    print(f"Is Active: {user.is_active}")
except User.DoesNotExist:
    print("User Transporter2 does not exist.")
except Exception as e:
    print(f"Error: {e}")
