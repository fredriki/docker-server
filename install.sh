set_env ()
{
    read -p 'Domain name: ' domain
    echo MYDOMAIN=${domain} > common.env
    echo TZ=\"$(cat /etc/timezone)\" >> common.env
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
}

set_env
install_certbot
install_docker
