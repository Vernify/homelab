#!/usr/bin/env bash
set -eu
echo "=== Container status ==="
docker ps --filter name=unifi --format "table {{.Names}}\t{{.Status}}\t{{.State}}"
echo
echo "=== Container health (if defined) ==="
docker inspect unifi-network-application --format '{{.State.Health.Status}}' 2>/dev/null || echo "No health check defined"
echo
echo "=== Last 30 lines of UniFi logs ==="
docker logs --tail 30 unifi-network-application 2>&1
echo
echo "=== Check if UniFi is listening on port 8443 inside container ==="
docker exec unifi-network-application netstat -tlnp 2>/dev/null | grep 8443 || echo "Port 8443 not yet listening inside container"
