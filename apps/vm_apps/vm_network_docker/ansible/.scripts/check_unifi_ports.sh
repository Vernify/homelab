#!/usr/bin/env bash
set -euo pipefail
echo '--- docker ps ---'
docker ps --format '{{.Names}}|{{.Status}}|{{.Ports}}' || true
echo
echo '--- listening ports (ss) ---'
ss -ltnp || true
echo
echo '--- curl 127.0.0.1:8443 (https) ---'
curl -skI https://127.0.0.1:8443 || true
echo
echo '--- curl 127.0.0.1:8080 (http) ---'
curl -sI http://127.0.0.1:8080 || true
echo
echo '--- docker inspect ports for unifi container ---'
cid=$(docker ps -q -f name=unifi-network-application || true)
if [ -n "$cid" ]; then
  docker inspect --format '{{json .NetworkSettings.Ports}}' "$cid" || true
else
  echo 'unifi container not found'
fi
echo
echo '--- last 300 lines of unifi logs ---'
if [ -n "$cid" ]; then
  docker logs --tail 300 "$cid" || true
fi
