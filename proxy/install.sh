#!/bin/bash
set -e

# Create plugins directory
mkdir -p ./traefik/plugins
echo "Downloading CrowdSec Traefik bouncer plugin from maxlerebourg/crowdsec-bouncer-traefik-plugin..."

# Download the plugin from the correct repository
curl -L https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin/releases/latest/download/crowdsec-bouncer-traefik-plugin.tar.gz -o ./traefik/plugins/crowdsec-bouncer-traefik-plugin.tar.gz

# Verify the download
if [ ! -s ./traefik/plugins/crowdsec-bouncer-traefik-plugin.tar.gz ]; then
    echo "ERROR: Downloaded file is empty or missing."
    rm -f ./traefik/plugins/crowdsec-bouncer-traefik-plugin.tar.gz
    exit 1
fi

# Check file type
echo "Checking file type..."
file ./traefik/plugins/crowdsec-bouncer-traefik-plugin.tar.gz

# Extract the plugin
echo "Extracting plugin..."
tar -xvzf ./traefik/plugins/crowdsec-bouncer-traefik-plugin.tar.gz -C ./traefik/plugins

# Clean up the tarball
rm ./traefik/plugins/crowdsec-bouncer-traefik-plugin.tar.gz

# Verify the plugin file exists
if [ ! -f ./traefik/plugins/crowdsec-bouncer-traefik-plugin.so ]; then
    echo "ERROR: Plugin file not found after extraction."
    echo "Contents of ./traefik/plugins:"
    ls -la ./traefik/plugins
    exit 1
fi

# Set permissions
chmod -R 755 ./traefik/plugins
echo "Plugin extracted successfully."

# Copy the common environment file
cp ../common.env ./.env

# Start CrowdSec container
echo "Starting CrowdSec container... please wait"
docker compose up -d crowdsec

# Wait for CrowdSec to be ready
echo "Waiting for CrowdSec to start..."
until docker exec crowdsec curl -s http://localhost:8080/v1/ready >/dev/null; do
   sleep 1
   echo -n "."
done
echo -e "\nCrowdSec is ready."

# Generate the CrowdSec bouncer API key
echo "Generating API key for CrowdSec bouncer..."
CROWDSEC_BOUNCER_KEY=$(docker exec crowdsec cscli bouncers add traefik-bouncer | grep "API key:" | awk '{print $3}')

# Check if the key was generated successfully
if [ -z "$CROWDSEC_BOUNCER_KEY" ]; then
    echo "ERROR: Failed to generate CrowdSec bouncer API key."
    exit 1
fi

# Append the key to the .env file
echo "CROWDSEC_BOUNCER_KEY=$CROWDSEC_BOUNCER_KEY" >> .env
echo "API key added to .env file."

# Stop CrowdSec container to apply the new key
echo "Stopping CrowdSec container..."
docker compose down crowdsec

# Start everything up
echo "Starting all services..."
docker compose up -d

echo "Setup complete! All services are running."
