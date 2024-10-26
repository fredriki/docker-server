#!/bin/bash

echo LLDAP_JWT_SECRET=$(echo $RANDOM | sha256sum | head -c 32; echo;) >> .env
echo LLDAP_KEY_SEED=$(echo $RANDOM | sha256sum | head -c 32; echo;) >> .env
