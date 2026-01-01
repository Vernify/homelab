#!/usr/bin/env bash
# SSH to UniFi devices and set inform URL
# Usage: Modify IPs below, then run this script

# Device IPs (update these with your actual IPs)
U6_IP="192.168.x.x"    # Replace with your U6 Enterprise IP
US8_IP="192.168.x.x"   # Replace with your US 8 switch IP

INFORM_URL="http://192.168.22.5:8080/inform"

echo "=== Setting inform URL on U6 Enterprise ($U6_IP) ==="
ssh -o StrictHostKeyChecking=no ubnt@$U6_IP "set-inform $INFORM_URL"
echo

echo "=== Setting inform URL on US 8 Switch ($US8_IP) ==="
ssh -o StrictHostKeyChecking=no ubnt@$US8_IP "set-inform $INFORM_URL"
echo

echo "Done! Check UniFi Controller - devices should show as 'Adopting' within 30 seconds"
echo "If they show 'Pending Adoption', click Adopt in the controller UI"
