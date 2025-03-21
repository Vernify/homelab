import requests
import os
import time
import ipaddress

NETBOX_URL = os.getenv('NETBOX_URL', 'http://localhost:8080')
ADMIN_USERNAME = os.getenv('ADMIN_USERNAME', 'admin')
ADMIN_PASSWORD = os.getenv('ADMIN_PASSWORD', 'admin')

HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
}

def get_api_token():
    data = {
        'username': ADMIN_USERNAME,
        'password': ADMIN_PASSWORD,
    }
    response = requests.post(f'{NETBOX_URL}/api/users/tokens/provision/', headers=HEADERS, json=data)
    response.raise_for_status()
    return response.json()['key']

def create_prefix(prefix, description, token):
    headers = HEADERS.copy()
    headers['Authorization'] = f'Token {token}'
    data = {
        'prefix': prefix,
        'description': description,
    }
    response = requests.post(f'{NETBOX_URL}/api/ipam/prefixes/', headers=headers, json=data)
    response.raise_for_status()
    return response.json()

def create_ip_address(address, description, token):
    headers = HEADERS.copy()
    headers['Authorization'] = f'Token {token}'
    data = {
        'address': address,
        'description': description,
    }
    response = requests.post(f'{NETBOX_URL}/api/ipam/ip-addresses/', headers=headers, json=data)
    response.raise_for_status()
    return response.json()

def main():
    # Wait for NetBox to be ready
    time.sleep(30)

    # Get API token
    token = get_api_token()

    # Example IP ranges and descriptions
    prefixes = [
        {'prefix': '192.168.1.0/24', 'description': 'Office Network'},
        {'prefix': '192.168.5.0/24', 'description': 'Office Network'},
        {'prefix': '192.168.20.0/24', 'description': 'Office Network'},
        {'prefix': '192.168.50.0/24', 'description': 'Office Network'},
        {'prefix': '192.168.22.0/24', 'description': 'Vernify'},
    ]

    for prefix in prefixes:
        create_prefix(prefix['prefix'], prefix['description'], token)
        network = ipaddress.ip_network(prefix['prefix'])
        for ip in network.hosts():
            create_ip_address(f'{ip}/{network.prefixlen}', f'Host in {prefix["description"]}', token)

if __name__ == '__main__':
    main()