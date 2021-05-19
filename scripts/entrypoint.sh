#!/bin/bash

source /etc/tls-refresh/.env
certsdir="/etc/haproxy/certs/"
certfile="$certsdir/$domain.pem"

rm -f "$certsdir/placeholder.pem"

if [ -f "$certfile" ]; then
  echo "Certificate exists, attempting to renew..."
  certbot renew --http-01-port 8080
  echo "Renewed certificate"
  exit
fi

echo "Certificate doesn't exist, generating one now..."

certbot certonly \
  --agree-tos \
  -d "$domain" \
  --email "$email" \
  --http-01-port 8080 \
  --non-interactive \
  --preferred-challenges http \
  --standalone

echo "Generated certificate"

cat \
  /etc/letsencrypt/live/"$domain"/fullchain.pem \
  /etc/letsencrypt/live/"$domain"/privkey.pem \
  > "$certfile"

echo "Updating HAProxy..."

echo -e "set ssl cert $haproxycert <<\n$(cat "$certfile")\n" | socat tcp-connect:gateway:9999 -
echo "show ssl cert *$haproxycert" | socat tcp-connect:gateway:9999 -
echo "commit ssl cert $haproxycert" | socat tcp-connect:gateway:9999 -
echo "show ssl cert $haproxycert" | socat tcp-connect:gateway:9999 -

echo "Updated HAProxy"
