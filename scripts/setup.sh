#!/bin/bash

cd "$(dirname "$0")"/..

mkdir -p etc/tls-refresh
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

sed -i "s/<domain>/$domain/" etc/haproxy/haproxy.cfg

echo "Building 'tls-refresh-certbot' image..."

docker build \
  -f certbot.Dockerfile \
  --no-cache \
  -t tls-refresh-certbot \
  .

echo "Built 'tls-refresh-certbot' image"
echo "Building 'tls-refresh-server' image..."

docker build \
  -f server.Dockerfile \
  --no-cache \
  -t tls-refresh-server \
  .

echo "Built 'tls-refresh-server' image"
echo "Generating self-signed certificate..."

mkdir -p etc/haproxy/certs
cd etc/haproxy/certs

openssl req \
  -x509 \
  -days 3650 \
  -newkey rsa:3072 \
  -nodes \
  -keyout key.pem \
  -out "$domain".pem \
  -subj "/CN=$domain/"

cat key.pem >> "$domain".pem
rm key.pem

touch placeholder

echo "Generated certificate"
