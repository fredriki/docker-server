#!/bin/bash

###############
# LLDAP STUFF #
###############
echo LLDAP_JWT_SECRET=$(openssl rand -base64 30 ; echo;) >> .env
echo LLDAP_KEY_SEED=$(openssl rand -base64 30 ; echo;) >> .env

read -sp 'LLDAP admin password: ' adm_pw
echo "This can later be found in .env in the auth folder"
echo LLDAP_LDAP_USER_PASS=${adm_pw} >> .env

# Getting variables from .env
source .env

##########################
# LLDAP + TINYAUTH STUFF #
##########################

# Creating a tinyauth user so tinyauth can talk to lldap (get users)
# This is done by starting lldap and running lldap-cli to create a user
# The user has read only

# Starting lldap only
docker compose  -f docker-compose.yml -f lldap-cli-port.ymlup -d lldap

# Creating password for tinyauth user
LLDAP_TINYAUTH_PASSWORD=$(openssl rand -base64 30 ; echo;)
echo LLDAP_TINYAUTH_PASSWORD=${LLDAP_TINYAUTH_PASSWORD} >> .env

echo "Getting cli for lldap"
# https://github.com/Zepmann/lldap-cli?tab=readme-ov-file#requirements
sudo apt install curl jq sed grep coreutils

git clone https://github.com/Zepmann/lldap-cli.git
cd lldap-cli

eval $(./lldap-cli -D admin -w ${adm_pw} login)
lldap-cli user add tinyath tinyath@${MYDOMAIN}
docker exec lldap ./lldap_set_password -b http://localhost:17170 -u tinyath -p ${LLDAP_TINYAUTH_PASSWORD} --admin-username ${adm_usr} --admin-password ${adm_pw}

# Change between lldap_strict_readonly and lldap_password_manager depending on 
# tinyauth should be able to manage passwords
lldap-cli user group add tinyauth lldap_strict_readonly
cd ..

docker compose down
