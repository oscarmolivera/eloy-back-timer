#!/bin/bash
# Akamai Linodes 1GB Log memory Configuration
# Usage every 5 minutes
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')
PUMA_MEM=$(ps aux | grep '[p]uma' | awk '{sum+=$6} END {printf "%.0f", sum/1024}')
PG_MEM=$(ps aux | grep '[p]ostgres' | awk '{sum+=$6} END {printf "%.0f", sum/1024}')
CADDY_MEM=$(ps aux | grep '[c]addy' | awk '{sum+=$6} END {printf "%.0f", sum/1024}')

echo "$TIMESTAMP | RAM: ${MEM_USED}/${MEM_TOTAL}MB | Swap: ${SWAP_USED}MB | Puma: ${PUMA_MEM}MB | PG: ${PG_MEM}MB | Caddy: ${CADDY_MEM}MB" >> ~/logs/memcheck.log

# Alert if memory > 900MB (leave 100MB breathing room)
if [ "$MEM_USED" -gt 900 ]; then
  echo "$TIMESTAMP CRITICAL: Memory at ${MEM_USED}MB!" >> ~/logs/memcheck.log
fi