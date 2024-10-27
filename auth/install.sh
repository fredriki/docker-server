#!/bin/bash

echo LLDAP_JWT_SECRET=$(echo $RANDOM | sha256sum | head -c 32; echo;) >> .env
echo LLDAP_KEY_SEED=$(echo $RANDOM | sha256sum | head -c 32; echo;) >> .env

read -p 'LLDAP admin user name: ' adm_usr
read -sp 'LLDAP admin password: ' adm_pw
echo "This can later be found in .env in the auth folder"
echo LLDAP_ADMIN_USERNAME=${adm_usr} >> .env
echo LLDAP_ADMIN_PASSWORD=${adm_pw} >> .env


# Parsing MYDOMAIN to dc dc thingie
# Read the text file
source .env
# Convert MYDOMAIN into the desired format
IFS='.' read -r subdomain domain <<< "$MYDOMAIN"
output="dc=${subdomain},dc=${domain}"
# Print the output to .env
echo BASE_DN=${output} >> .env


# Setting up LLDAP user for Authelia
LLDAP_AUTHELIA_PASSWORD=$(echo $RANDOM | sha256sum | head -c 32; echo;)
echo LLDAP_AUTHELIA_PASSWORD=${LLDAP_AUTHELIA_PASSWORD=} >> .env


docker-compose up -d

echo "Waiting for everything to start"
sleep 10

echo "Getting cli for lldap"
git clone https://github.com/Zepmann/lldap-cli.git
cd lldap-cli
eval $(./lldap-cli -D ${adm_usr} -w ${adm_pw} login)
lldap-cli user add authelia authelia@${MYDOMAIN} -p ${LLDAP_AUTHELIA_PASSWORD}
# Change between lldap_strict_readonly and lldap_password_manager depending on 
# authelia should be able to manage passwords
lldap-cli user group add authelia lldap_strict_readonly
cd ..

docker-compose down
