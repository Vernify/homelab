#!/usr/bin/env bash
set -euo pipefail
echo '--- ss listening ---'
ss -ltnp || true
echo
echo '--- iptables -S ---'
iptables -S || true
echo
echo '--- iptables -L -n ---'
iptables -L -n || true
echo
echo '--- nft list ruleset ---'
command -v nft >/dev/null 2>&1 && nft list ruleset || echo 'nft not present'
echo
echo '--- ufw status ---'
command -v ufw >/dev/null 2>&1 && ufw status verbose || echo 'ufw not present'
echo
echo '--- curl to local 127.0.0.1:8080 and VM IP 192.168.22.5:8080 ---'
curl -sI http://127.0.0.1:8080 || true
echo
curl -sI http://192.168.22.5:8080 || true
