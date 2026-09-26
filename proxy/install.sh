#!/bin/bash
set -e

# --- Step 1: Install CrowdSec Bouncer on the Host ---
echo "Installing CrowdSec firewall bouncer on the host..."

# Install the firewall bouncer
sudo apt-get update
sudo apt-get install -y crowdsec-firewall-bouncer

# Configure the bouncer (we'll update the API key later)
sudo tee /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml > /dev/null <<EOL
api_key: ""
api_url: "http://localhost:8080"
mode: iptables
iptables_chain: CROWDSEC
EOL

# Enable and start the bouncer service
sudo systemctl enable crowdsec-firewall-bouncer
sudo systemctl start crowdsec-firewall-bouncer

echo "CrowdSec firewall bouncer installed and started."

---

# --- Step 2: Set Up CrowdSec in Docker ---
echo "Setting up CrowdSec in Docker..."

# Create directories for CrowdSec and Traefik logs
mkdir -p ./crowdsec/config
mkdir -p ./traefik/logs

# Copy the common environment file
cp ../common.env ./.env

# Start CrowdSec container
echo "Starting CrowdSec container..."
docker compose up -d crowdsec

# Wait for CrowdSec to be ready
echo "Waiting for CrowdSec to start..."
until docker exec crowdsec curl -s http://localhost:8080/v1/ready >/dev/null; do
   sleep 1
   echo -n "."
done
echo -e "\nCrowdSec is ready."

# Generate the CrowdSec bouncer API key for the host bouncer
echo "Generating API key for CrowdSec firewall bouncer..."
CROWDSEC_BOUNCER_KEY=$(docker exec crowdsec cscli bouncers add crowdsec-firewall-bouncer | grep "API key:" | awk '{print $3}')

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

---

# --- Step 3: Configure Traefik ---
echo "Configuring Traefik..."
docker compose up -d traefik

echo "All services are running."
echo "CrowdSec firewall bouncer is active on the host."
echo "Traefik logs are being parsed by CrowdSec in Docker."
