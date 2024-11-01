#!/bin/bash

set_env ()
{
    # Setting common environment stuff
    read -p 'Domain name: ' domain
    echo MYDOMAIN=${domain} > common.env
    echo TZ=$(cat /etc/timezone) >> common.env

    # Copy common environment and run containers install.sh if exist
    for d in */ ; do
        cd ${d}
        cp ../common.env .env
        if test -f install.sh; then
            bash install.sh
        fi
        cd ..
    done
}

install_certbot ()
{
   sudo apt install certbot
}

install_docker ()
{
   sudo apt install docker docker-compose
   sudo usermod -aG docker ${USER}
   #sudo docker network create proxy_net
}

install_lldap_cli_deps ()
{
    # https://github.com/Zepmann/lldap-cli?tab=readme-ov-file#requirements
    sudo apt install curl jq sed grep coreutils
}

install_genereal_deps ()
{
    sudo apt install openssl
}

sudo apt update
install_lldap_cli_deps
install_certbot
install_docker
set_env
