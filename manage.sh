cert ()
{
    MYDOMAIN=$(cat common.env | grep MYDOMAIN | cut -d "=" -f2 | xargs)
    echo "Fixing certificate for ${MYDOMAIN} :)"

    sudo certbot certonly --manual --preferred-challenge dns -d ${MYDOMAIN} -d "*.${MYDOMAIN}"

    sudo cp /etc/letsencrypt/live/${MYDOMAIN}/privkey.pem /etc/letsencrypt/live/${MYDOMAIN}/${MYDOMAIN}.key
    echo "/etc/letsencrypt/live/${MYDOMAIN}/privkey.pem /etc/letsencrypt/live/${MYDOMAIN}/${MYDOMAIN}.key"
    sudo cp /etc/letsencrypt/live/${MYDOMAIN}/fullchain.pem /etc/letsencrypt/live/${MYDOMAIN}/${MYDOMAIN}.crt
    echo "cp /etc/letsencrypt/live/${MYDOMAIN}/fullchain.pem /etc/letsencrypt/live/${MYDOMAIN}/${MYDOMAIN}.crt"
}

stop ()
{
    for d in */ ; do
        cd ${d} 
        docker-compose down 
        cd ..
    done
}

update ()
{
    for d in */ ; do
        cd ${d}
        docker-compose pull
        docker-compose up -d --remove-orphans
        cd ..
    done
    docker image prune
}

reset ()
{
    stop 
    # Removes everything except managed by git, need to run install.sh after this
    sudo git clean -f -d -x
}

case "$1" in
    cert) cert;;
    update) update;;
    reset) reset;;
esac

