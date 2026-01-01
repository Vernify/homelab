#!/usr/bin/env bash
set -eu
echo "=== docker ps (unifi) ==="
docker ps --format "{{.Names}} {{.Image}}" | grep -i unifi || true
echo
echo "=== curl 127.0.0.1:8080 ==="
curl -sv --connect-timeout 5 http://127.0.0.1:8080 || true
echo
echo "=== curl 192.168.22.5:8080 ==="
curl -sv --connect-timeout 5 http://192.168.22.5:8080 || true
echo
echo "=== curl 172.20.0.2:8080 ==="
curl -sv --connect-timeout 5 http://172.20.0.2:8080 || true
echo
echo "=== ss -tnp | grep 8080 ==="
ss -tnp | grep 8080 || true
echo
echo "=== docker logs (tail 100) unifi-network-application ==="
docker logs --tail 100 unifi-network-application || true
