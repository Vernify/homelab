#!/usr/bin/env bash
set -eu
echo "=== Last 100 lines of UniFi logs ==="
docker logs --tail 100 unifi-network-application 2>&1
echo
echo "=== Check for adoption/inform errors ==="
docker logs --tail 500 unifi-network-application 2>&1 | grep -i -E "(adopt|inform|error|exception|fail)" | tail -50
