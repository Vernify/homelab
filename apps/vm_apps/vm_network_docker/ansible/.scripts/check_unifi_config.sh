#!/usr/bin/env bash
set -eu
echo "=== Check UniFi system.properties file ==="
docker exec unifi-network-application cat /usr/lib/unifi/data/system.properties 2>/dev/null || echo "File not found"
echo
echo "=== Check if db.mongo.uri is set correctly ==="
docker exec unifi-network-application grep -E "(db\.mongo|unifi\.https)" /usr/lib/unifi/data/system.properties 2>/dev/null || echo "No mongo/https settings found"
