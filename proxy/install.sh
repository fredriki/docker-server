#!/bin/bash
set -e

# --- Step 1: Set Up CrowdSec in Docker ---
echo "Setting up CrowdSec in Docker..."

# Create directories for CrowdSec and Traefik logs
mkdir -p ./crowdsec/config
mkdir -p ./crowdsec/data
mkdir -p ./traefik/logs

# Copy the common environment file
cp ../common.env ./.env

# Start CrowdSec container
echo "Starting CrowdSec container..."
docker compose up -d crowdsec

# Wait for CrowdSec to be ready
echo "Waiting for CrowdSec to start..."
until docker exec crowdsec cscli lapi status >/dev/null 2>&1; do 
    sleep 1
    echo -n "."
done
echo -e "\nCrowdSec is ready."

# Generate the CrowdSec bouncer API key for the host bouncer
echo "Generating API key for CrowdSec firewall bouncer..."
CROWDSEC_BOUNCER_KEY=$(docker exec crowdsec cscli bouncers add crowdsec-firewall-bouncer | grep -oE '[a-zA-Z0-9+/]{40,}')

# Check if the key was generated successfully
if [ -z "$CROWDSEC_BOUNCER_KEY" ]; then
    echo "ERROR: Failed to generate CrowdSec bouncer API key."
    exit 1
fi

# Update the bouncer configuration with the new API key
echo "Updating CrowdSec firewall bouncer configuration..."
sudo sed -i "s|api_key: \"\"|api_key: \"$CROWDSEC_BOUNCER_KEY\"|" /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml

# Restart the bouncer to apply the new key
sudo systemctl restart crowdsec-firewall-bouncer
echo "CrowdSec firewall bouncer updated with API key and restarted."

# --- Step 2: Start everyting else ---
echo "Starting all services..."
docker compose up -d 

echo "All services are running."
echo "CrowdSec firewall bouncer is active on the host."
echo "CrowdSec in Docker is parsing Traefik, SSH, and Cockpit logs."
