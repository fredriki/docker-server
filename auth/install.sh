#!/bin/bash

###############
# LLDAP STUFF #
###############
echo LLDAP_JWT_SECRET=$(openssl rand -base64 30 ; echo;) >> .env
echo LLDAP_KEY_SEED=$(openssl rand -base64 30 ; echo;) >> .env

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

# Creating a authelia user so authelia can talk to lldap
docker-compose up -d lldap

echo "Waiting for everything to start"

# openssl rand -base64 18
# echo TEST=$(openssl rand -base64 30 ; echo;) >> test.env
LLDAP_AUTHELIA_PASSWORD=$(openssl rand -base64 30 ; echo;)
echo LLDAP_AUTHELIA_PASSWORD=${LLDAP_AUTHELIA_PASSWORD} >> .env

sleep 10

echo "Getting cli for lldap"
git clone https://github.com/Zepmann/lldap-cli.git
cd lldap-cli
eval $(./lldap-cli -D ${adm_usr} -w ${adm_pw} login)
lldap-cli user add authelia authelia@${MYDOMAIN}
docker exec lldap ./lldap_set_password -b http://localhost:17170 -u authelia -p ${LLDAP_AUTHELIA_PASSWORD} --admin-username ${adm_usr} --admin-password ${adm_pw}

# Change between lldap_strict_readonly and lldap_password_manager depending on 
# authelia should be able to manage passwords
lldap-cli user group add authelia lldap_strict_readonly
cd ..

docker-compose down


##################
# AUTHELIA STUFF #
##################

# Create a own config files for cookies so we don't manage domain names
# in a git-versioned file.
cat >/authelia/cookies.yml <<EOL
session:
  name: 'authelia_session'
  same_site: 'lax'
  inactivity: '5m'
  expiration: '1h'
  remember_me: '1M'
  cookies:
    - domain: '${MYDOMAIN}'
      authelia_url: 'https://authelia.${MYDOMAIN}'
      default_redirection_url: 'https://${MYDOMAIN}'
      name: 'authelia_session'
      same_site: 'lax'
      inactivity: '5m'
      expiration: '1h'
      remember_me: '1d'
EOL

echo AUTHELIA_STORAGE_ENCRYPTION_KEY=$(echo $RANDOM | sha256sum | head -c 32; echo;) >> .env
echo AUTHELIA_PW_RESET_JWT_SECRET=$(echo $RANDOM | sha256sum | head -c 32; echo;) >> .env
echo AUTHELIA_SESSION_SECRET=$(echo $RANDOM | sha256sum | head -c 32; echo;) >> .env
