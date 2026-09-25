#!/bin/bash

# Create plugins directory and download the CrowdSec Traefik bouncer plugin
mkdir -p ./traefik/plugins
echo "Downloading CrowdSec Traefik bouncer plugin..."
curl -L https://github.com/crowdsecurity/crowdsec-traefik-bouncer/releases/latest/download/crowdsec-traefik-bouncer.tar.gz -o ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz
tar -xvzf ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz -C ./traefik/plugins
echo "Plugin downloaded and extracted."

# Copy the common environment file
cp ../common.env ./.env

# Start CrowdSec container
echo "Starting CrowdSec container... please wait"
docker compose up -d crowdsec

# Wait for CrowdSec to fully start (with a progress indicator)
echo "Waiting for CrowdSec to fully start (60 seconds)..."
for i in {1..60}; do
   sleep 1
   echo -n "."
done
echo -e "\nDone waiting."

# Generate the CrowdSec bouncer API key
echo "Generating API key for CrowdSec bouncer..."
CROWDSEC_BOUNCER_KEY=$(docker exec crowdsec cscli bouncers add traefik-bouncer | grep "API key:" | awk '{print $3}')

# Check if the key was generated successfully
if [ -z "$CROWDSEC_BOUNCER_KEY" ]; then
    echo "ERROR: Failed to generate CrowdSec bouncer API key."
    echo "Check if CrowdSec container is running and try again."
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

echo "Setup complete! All services are running."mkdir -p ./traefik/plugins
curl -L https://github.com/crowdsecurity/crowdsec-traefik-bouncer/releases/latest/download/crowdsec-traefik-bouncer.tar.gz -o ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz
tar -xvzf ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz -C ./traefik/plugins


cp ../common.env ./.env
# Start crowdsec
echo "Starting docker container... please wait"
docker compose up -d crowdsec
echo "Sleeping for 1 minute to be sure that crowdsec is fully started"
echo "|------------------------ sleeping ------------------------|"
for i in {1..60}
do
   sleep 1
   echo -n "."
done
echo ""

# Generate the key and store it in a variable
echo "Generating api key for crowdsec"
CROWDSEC_BOUNCER_KEY=$(docker exec crowdsec cscli bouncers add traefik-bouncer | grep "API key:" | awk '{print $3}')

# Append the key to your .env file
echo "CROWDSEC_BOUNCER_KEY=$CROWDSEC_BOUNCER_KEY" >> .env
docker compose down crowdsec

echo "All done, starting everything up"

docker compose up -d
