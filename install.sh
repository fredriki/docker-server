set_common_env ()
{
    read -p 'Domain name: ' domain
    echo MYDOMAIN=${domain} > common.env
    echo TZ=\"$(cat /etc/timezone)\" >> common.env    
}

install_certbot ()
{
   sudo apt install certbot
}

install_docker ()
{
   sudo apt install docker docker-compose
   sudo usermod -aG docker ${USER}
}

set_common_env
install_certbot
install_docker
