#Lägg till /usr/sbin till PATH:
#export PATH="$PATH:/usr/sbin"

#Installera sudo:
#Logga in som superuser med su
#apt install sudo
#usermod -a -G sudo myadmin

#Behöver logga ut innan det funkar...


set_env_all_dirs ()
{
    for d in */ ; do
        cd ${d} 
        	    # SET YOUR DOMAIN HERE
        echo MYDOMAIN=iixn.se >> .env
        echo EXTRADOMAIN=1a.nu >> .env
        echo TZ="Europe/Stockholm" >> .env
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

unattended_upgrades ()
{
   sudo apt install unattended-upgrades
   sudo apt install apt-config-auto-update
}

local_dns ()
{
   mkdir vpn-dns/etc-dnsmasq.d
   touch vpn-dns/etc-dnsmasq.d/02-lan.conf
   IPV4_PUBLIC=$(ip -o -4 route show default | egrep -o 'dev [^ ]*' | awk '{print $2}' | xargs ip -4 addr show | grep 'inet ' | awk '{print $2}' | grep -o "^[0-9.]*"  | tr -cd '\11\12\15\40-\176' | head -1)
   echo "address=/iixn.se/${IPV4_PUBLIC}" | sudo tee vpn-dns/etc-dnsmasq.d/02-lan.conf 
   docker network create --subnet=172.22.0.0/16 docker_net
}

set_env_all_dirs
install_certbot
install_docker
unattended_upgrades
local_dns

