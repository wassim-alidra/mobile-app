import requests
import json

# Replace with your actual values
BASE_URL = 'http://127.0.0.1:8000'
LOGIN_URL = f'{BASE_URL}/api/token/'
DELIVERIES_URL = f'{BASE_URL}/api/market/deliveries/'

# 1. Login
login_data = {
    'username': 'Transporter2',
    'password': '123'
}

try:
    response = requests.post(LOGIN_URL, json=login_data)
    response.raise_for_status()
    tokens = response.json()
    token = tokens['access']
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    response = requests.get(DELIVERIES_URL, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        print(f"Data type: {type(data)}")
        if isinstance(data, dict):
            print(f"Keys: {data.keys()}")
            if 'results' in data:
                print(f"Results count: {len(data['results'])}")
                if data['results']:
                    print(json.dumps(data['results'][0], indent=2))
        else:
            print(f"List length: {len(data)}")
            if data:
                print(json.dumps(data[0], indent=2))
    else:
        print(f"Failed. Status: {response.status_code}")

except Exception as e:
    print(f"An error occurred: {e}")
