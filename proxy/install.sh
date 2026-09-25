mkdir -p ./traefik/plugins
curl -L https://github.com/crowdsecurity/crowdsec-traefik-bouncer/releases/latest/download/crowdsec-traefik-bouncer.tar.gz -o ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz
tar -xvzf ./traefik/plugins/crowdsec-traefik-bouncer.tar.gz -C ./traefik/plugins


cp ../common.env ./.env
# Start crowdsec
echo "Starting docker container... please wait"
docker compose up -d crowdsec
echo "Sleeping for 1 minute to be sure that crowdsec is fully started"
echo "|------------------------ sleeping ------------------------|"
for i in {1..60}
do
   sleep 1
   echo -n "."
done
echo ""

# Generate the key and store it in a variable
echo "Generating api key for crowdsec"
CROWDSEC_BOUNCER_KEY=$(docker exec crowdsec cscli bouncers add traefik-bouncer | grep "API key:" | awk '{print $3}')

# Append the key to your .env file
echo "CROWDSEC_BOUNCER_KEY=$CROWDSEC_BOUNCER_KEY" >> .env
docker compose down crowdsec

echo "All done, starting everything up"

docker compose up -d
