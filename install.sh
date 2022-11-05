#!/bin/bash

set_env ()
{
    # Setting common environment stuff
    read -p 'Domain name: ' domain
    echo MYDOMAIN=${domain} > common.env
    echo TZ=$(cat /etc/timezone) >> common.env
    # Need to match subnet in network create
    echo DOCKER_NET=10.0.0 >> common.env
    
    # Copy common environment and run containers install.sh if exist
    for d in */ ; do
        cd ${d}
        cp ../common.env .env
        if test -f install.sh; then
            install.sh
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
   sudo docker network create --subnet=10.0.0.0/8 docker_net
}

set_env
install_certbot
install_docker
