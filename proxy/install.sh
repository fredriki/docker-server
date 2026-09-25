#!/bin/bash
set -e
# Remove earlier .env file
rm .env

# Create plugins directory
mkdir -p ./traefik/plugins
echo "Downloading CrowdSec Traefik bouncer plugin..."

# Download the plugin with verbose output
echo "Downloading from GitHub..."
curl -vL -H "Accept: application/octet-stream" \
  https://github.com/crowdsecurity/crowdsec-traefik-bouncer/releases/latest/download/crowdsec-traefik-bouncer.tar.gz \
  -o ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz

# Verify the download
if [ ! -s ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz ]; then
    echo "ERROR: Downloaded file is empty or missing."
    rm -f ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz
    exit 1
fi

# Check file type
echo "Checking file type..."
file ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz

# Inspect the tarball contents
echo "Inspecting tarball contents..."
if ! tar -tzf ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz >/dev/null 2>&1; then
    echo "ERROR: File is not a valid tarball. Trying wget instead..."
    rm -f ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz
    wget https://github.com/crowdsecurity/crowdsec-traefik-bouncer/releases/latest/download/crowdsec-traefik-bouncer.tar.gz \
      -O ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz
    if ! tar -tzf ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz >/dev/null 2>&1; then
        echo "ERROR: Still not a valid tarball. Check the URL or your network."
        exit 1
    fi
fi

# Extract the plugin (strip top-level directory if present)
echo "Extracting plugin..."
tar -xvzf ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz -C ./traefik/plugins --strip-components=1

# Clean up the tarball
rm ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz

# Verify the plugin file exists
if [ ! -f ./traefik/plugins/crowdsec-traefik-bouncer.so ]; then
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

echo "Setup complete! All services are running."#!/bin/bash
set -e

# Create plugins directory
mkdir -p ./traefik/plugins
echo "Downloading CrowdSec Traefik bouncer plugin..."

# Download the plugin
curl -L https://github.com/crowdsecurity/crowdsec-traefik-bouncer/releases/latest/download/crowdsec-traefik-bouncer.tar.gz -o ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz

# Verify the download
if [ ! -s ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz ]; then
    echo "ERROR: Downloaded file is empty or missing."
    exit 1
fi

# Inspect the tarball contents
echo "Inspecting tarball contents..."
tar -tzf ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz

# Extract the plugin (strip top-level directory if present)
echo "Extracting plugin..."
tar -xvzf ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz -C ./traefik/plugins --strip-components=1

# Clean up the tarball
rm ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz

# Verify the plugin file exists
if [ ! -f ./traefik/plugins/crowdsec-traefik-bouncer.so ]; then
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

echo "Setup complete! All services are running."#!/bin/bash

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
