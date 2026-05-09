import os
import sys
import django

# Set up Django environment
sys.path.append(r'c:\Users\ASUS\Documents\Agrigov\team-work\backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'agri_gov_market.settings')
django.setup()

from market.models import Product

products_no_catalog = Product.objects.filter(catalog__isnull=True)
print(f"Products with no catalog: {products_no_catalog.count()}")
for p in products_no_catalog:
    print(f"ID: {p.id}, Farmer: {p.farmer.username}")
