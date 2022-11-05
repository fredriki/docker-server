#!/bin/bash

# Setting nextcloud env
# random passwords
# will be stored (and possible to be read) in .env

echo MYSQL_HOST=db >> .env
echo REDIS_HOST=redis >> .env
echo MYSQL_DATABASE=nextcloud >> .env
echo MYSQL_USER=nextcloud >> .env
echo MYSQL_ROOT_PASSWORD=$(echo $RANDOM | sha256sum | head -c 20; echo;) >> .env
echo MYSQL_PASSWORD=$(echo $RANDOM | sha256sum | head -c 20; echo;) >> .env

# Let user choose admin user name and password
# will also be stored readable in .env

read -p 'Admin user name: ' adm_usr
read -sp 'Admin password: ' adm_pw
echo "This can later be found in .env in the cloud folder"
echo NEXTCLOUD_ADMIN_USER=${adm_usr} >> .env
echo NEXTCLOUD_ADMIN_PASSWORD=${adm_pw} >> .env

# Starting nextcloud and waiting a while for DB and everything to be set up

echo "Starting docker container... please wait"
docker-compose up -d
echo "Sleeping for 1 minute to be sure that nextcloud is fully started"
echo "|------------------------ sleeping ------------------------|"
for i in {1..60}
do
   sleep 1
   echo -n "."
done
echo ""

# Installing desired nextcloud packages/apps
INSTALL="docker-compose exec -u www-data nc php occ app:install"
${INSTALL} music
