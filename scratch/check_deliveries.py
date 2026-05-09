import os
import sys
import django

# Set up Django environment
sys.path.append(r'c:\Users\ASUS\Documents\Agrigov\team-work\backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'agri_gov_market.settings')
django.setup()

from market.models import Delivery
from django.contrib.auth import get_user_model
User = get_user_model()

try:
    user = User.objects.get(username='Transporter2')
    deliveries = Delivery.objects.filter(transporter=user)
    print(f"Total deliveries for Transporter2: {deliveries.count()}")
    for d in deliveries:
        print(f"ID: {d.id}, Status: {d.status}, Order: {d.order_id}")
    
    # Check if there are ANY deliveries at all
    all_deliveries = Delivery.objects.all()
    print(f"Total deliveries in DB: {all_deliveries.count()}")
    
except Exception as e:
    print(f"Error: {e}")
