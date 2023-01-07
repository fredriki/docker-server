#!/bin/bash

# Setting vaulwarden env
# random passwords
# will be stored (and possible to be read) in .env

# Let user choose admin user name and password
# will also be stored readable in .env

read -sp 'Admin password for vaulwarden: ' adm_pw
echo "This can later be found in .env in the cloud folder"
echo ADM_PW=${adm_pw} >> .env

docker-compose up -d

