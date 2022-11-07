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
   sudo docker network create proxy_net
}

local_dns ()
{
   mkdir vpn-dns/etc-dnsmasq.d
   touch vpn-dns/etc-dnsmasq.d/02-lan.conf
   IPV4_PUBLIC=$(ip -o -4 route show default | egrep -o 'dev [^ ]*' | awk '{print $2}' | xargs ip -4 addr show | grep 'inet ' | awk '{print $2}' | grep -o "^[0-9.]*"  | tr -cd '\11\12\15\40-\176' | head -1)
   echo "address=/XXXXXX/${IPV4_PUBLIC}" | sudo tee vpn-dns/etc-dnsmasq.d/02-lan.conf 
   docker network create --subnet=172.22.0.0/16 docker_net
}

set_env
install_certbot
install_docker
