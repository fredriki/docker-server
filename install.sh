#!/bin/bash

set_env ()
{
    # Setting common environment stuff
    read -p 'Domain name: ' domain
    echo MYDOMAIN=${domain} > common.env
    echo TZ=$(cat /etc/timezone) >> common.env

    # Convert MYDOMAIN into the desired format
    IFS='.' read -r subdomain topdomain <<< "$domain"
    output="dc=${subdomain},dc=${topdomain}"
    # Print the output to .env
    echo BASE_DN=${output} >> common.env

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


install_genereal_deps ()
{
    sudo apt install openssl
}

sudo apt update
install_certbot
install_docker

base_access_control="
access_control:
  default_policy: 'deny'

  networks:
    - name: 'internal'
      networks:
        - '192.168.0.0/24'

  rules:
  
"
echo ${base_access_control} > auth/authelia/access_control.yml

set_env
