#!/usr/bin/env bash
set -eu
echo "=== docker network ls ==="
docker network ls
echo
echo "=== unifi-db container networks ==="
docker inspect unifi-db --format 'Networks: {{range $net, $cfg := .NetworkSettings.Networks}}{{$net}} {{end}}'
echo
echo "=== unifi-network-application container networks ==="
docker inspect unifi-network-application --format 'Networks: {{range $net, $cfg := .NetworkSettings.Networks}}{{$net}} {{end}}'
echo
echo "=== unifi-net network exists? ==="
docker network ls | grep unifi-net || echo "NOT FOUND"
echo
echo "=== current compose file ==="
cat /opt/unifi/docker-compose.yml
