#!/bin/bash

# Akamai Linodes 1GB EloyTimer Deployment Script
set -e

# Load rbenv (not loaded in non-interactive shells)
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - bash)"

APP_DIR="/home/deploy/apps/eloy-back-timer"
cd "$APP_DIR"

echo "=== Deploying EloyTimer ==="
echo "$(date '+%Y-%m-%d %H:%M:%S') Deploy started" >> ~/logs/deploy.log

# Pull latest code
echo "→ Pulling latest code..."
git pull origin main

# Install gems (skip dev/test)
echo "→ Installing gems..."
bundle install --quiet

# Run migrations
echo "→ Running migrations..."
export $(grep -v '^#' .env.production | xargs)
bin/rails db:migrate

# Restart Puma (zero-ish downtime with USR2 for phased restart)
echo "→ Restarting Puma..."
sudo systemctl restart eloy-timer

# Wait for health check
echo "→ Waiting for health check..."
sleep 3
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/up)
if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ Deploy successful! (HTTP $HTTP_CODE)"
  echo "$(date '+%Y-%m-%d %H:%M:%S') Deploy successful" >> ~/logs/deploy.log
else
  echo "❌ Health check failed! (HTTP $HTTP_CODE)"
  echo "$(date '+%Y-%m-%d %H:%M:%S') Deploy FAILED (HTTP $HTTP_CODE)" >> ~/logs/deploy.log
  echo "Check logs: sudo journalctl -u eloy-timer -n 50"
  exit 1
fi
