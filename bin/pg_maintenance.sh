#!/bin/bash

# Akamai Linodes 1GB Weekly PostgreSQL Maintenance Script
# Usage: Run once a week (e.g., via cron)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "$TIMESTAMP Starting weekly maintenance..." >> ~/logs/pg_maintenance.log

# Reindex and vacuum
sudo -u postgres psql -d eloy_back_timer_production -c "VACUUM ANALYZE;" 2>&1 >> ~/logs/pg_maintenance.log
sudo -u postgres psql -d eloy_back_timer_production -c "REINDEX DATABASE eloy_back_timer_production;" 2>&1 >> ~/logs/pg_maintenance.log

echo "$TIMESTAMP Maintenance complete." >> ~/logs/pg_maintenance.log
