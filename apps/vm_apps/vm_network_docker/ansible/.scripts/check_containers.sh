#!/usr/bin/env bash
set -euo pipefail
echo '--- docker ps ---'
docker ps --format '{{.Names}}|{{.Status}}|{{.Ports}}' || true
echo
echo '--- docker ps -a ---'
docker ps -a --format '{{.Names}}|{{.Status}}|{{.Ports}}' || true
echo
echo '--- docker-compose ps (if available) ---'
if command -v docker-compose >/dev/null 2>&1; then
  docker-compose ps || true
else
  echo 'docker-compose not found'
fi
echo
echo '--- logs: twingate and netbox (last 50 lines) ---'
for c in twingate netbox; do
  id=$(docker ps -q -f name="$c" || true)
  if [ -n "$id" ]; then
    echo "\nLogs for $c (container $id):"
    docker logs --tail 50 "$id" || true
  else
    echo "$c: not running"
  fi
done
