#!/usr/bin/env bash
set -eu
echo "=== Setting inform host override in system.properties ==="
docker exec unifi-network-application bash -c "
  # Backup the file first
  cp /usr/lib/unifi/data/system.properties /usr/lib/unifi/data/system.properties.bak
  
  # Add or update system_ip
  if grep -q '^system_ip=' /usr/lib/unifi/data/system.properties; then
    sed -i 's/^system_ip=.*/system_ip=192.168.22.5/' /usr/lib/unifi/data/system.properties
  else
    echo 'system_ip=192.168.22.5' >> /usr/lib/unifi/data/system.properties
  fi
  
  echo 'Inform host set to 192.168.22.5'
  grep '^system_ip=' /usr/lib/unifi/data/system.properties
"
echo
echo "=== Restarting UniFi container to apply changes ==="
docker restart unifi-network-application
echo "Container restarted. Wait 30-60 seconds for UniFi to come back up."
