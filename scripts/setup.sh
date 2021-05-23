#!/bin/bash

cd "$(dirname "$0")"/..

mkdir -p etc/tls-refresh logs
touch etc/tls-refresh/.env
source etc/tls-refresh/.env

if [ -z "$domain" ]; then
  read -rp "Please enter your domain: " domain

  if [ -z "$domain" ]; then
    echo "You must provide a domain"
    exit 1
  fi

  echo "domain=$domain" >> etc/tls-refresh/.env
fi

if [ -z "$email" ]; then
  read -rp "Please enter your email: " email

  if [ -z "$email" ]; then
    echo "You must provide an email"
    exit 1
  fi

  echo "email=$email" >> etc/tls-refresh/.env
fi

sed "s/<domain>/$domain/" etc/haproxy/example.haproxy.cfg > etc/haproxy/haproxy.cfg

cd scripts

bash build-certbot-image.sh &
bash build-server-image.sh &

wait

bash generate-cert.sh

cd ..

echo "#!/bin/sh

/usr/bin/docker run \
  --name tls-refresh-certbot \
  --network=tls-refresh \
  --rm \
  -v $PWD/etc/haproxy/certs:/etc/haproxy/certs \
  -v $PWD/etc/letsencrypt/renewal-hooks/deploy:/etc/letsencrypt/renewal-hooks/deploy:ro \
  -v $PWD/etc/tls-refresh:/etc/tls-refresh:ro \
  tls-refresh-certbot \
  > $PWD/logs/tls-refresh-certbot.out \
  2> $PWD/logs/tls-refresh-certbot.err" |
  sudo tee /etc/cron.weekly/tls-refresh-certbot

sudo chmod +x /etc/cron.weekly/tls-refresh-certbot
