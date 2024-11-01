#!/bin/bash

# Check if service name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <service-name>"
  exit 1
fi

SERVICE_NAME=$1

# Create directory with service name
mkdir -p "$SERVICE_NAME"

# Create docker-compose.yml file in the directory
cat <<EOL > "$SERVICE_NAME/docker-compose.yml"
version: '3.9'

services:
  $SERVICE_NAME:
    image: $SERVICE_NAME/$SERVICE_NAME
    container_name: $SERVICE_NAME
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.$SERVICE_NAME.rule=Host(\`${SERVICE_NAME}.\${MYDOMAIN}\`)"
      - "traefik.http.routers.$SERVICE_NAME.middlewares=authelia@docker"
      - "traefik.http.services.$SERVICE_NAME.loadbalancer.server.port=80"
    networks:
      - proxy

networks:
  proxy:
    external: true
      
EOL

echo "docker-compose.yml for service $SERVICE_NAME created successfully in $SERVICE_NAME directory."
