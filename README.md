# docker-server
Repository for docker-compose files and setup for my docker server.

The goal is to be able to run install.sh on a new machine and have everything setup automatically.

New users should only be added to lldap, as well as access via groups.

Certificate generation is not included in this, but one wildcard certificate for the domain 
is expected to be provided where certbot usually puts them.

## Installation
Start with running install.sh




## Components

### Scripts

#### install.sh
Super simple thing asking for domain-name
- It will install dependencies.
- It will create a common.env file for containers installations script to use further on as docker .env-file.
- It will run install.sh in each folder if it exists.

Some parts will ask for a admin password for different services...

#### manage.sh
Helper script for fixing certs, starting/stopping/updating all the containers.

#### create_template_service.sh
To ease creating new services.

### Proxy
Traefik as reverse-proxy and a docker-socket proxy.

### Auth
LLDAP combined with Authelia. Use with traefik middleware.

Note: One must customize auth/authelia/access_rules.yml to suit one needs

### Wiki
Wikmd as simple wiki, is nice.

### Cloud
Nextcloud, some customization to get everything to work is needed.


## TODO
- [ ] Password manager with LDAP connection (Vaultwarden?)
- [ ] Nextcloud LDAP automatic integration during install
- [ ] Email server
- [ ] Add media stack
- [ ] Add linux iso downloader to media stack
- [ ] Add VPN for iso downloader
- [ ] Enable update of common.env and .env in install-scripts
- [ ] Add homepage


