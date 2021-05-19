#!/bin/bash

cd "$(dirname "$0")"/..
source etc/tls-refresh/.env

if [ -z "$domain" ]; then
  echo "Must specify 'domain' in etc/tls-refresh/.env"
  exit 1
fi

if [ -z "$email" ]; then
  echo "Must specify 'email' in etc/tls-refresh/.env"
  exit 1
fi

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
echo "Creating 'tls-refresh' docker network"

docker network create tls-refresh

echo "Created 'tls-refresh' docker network"
echo "Generating self-signed, placeholder certificate"

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

echo "Generated certificate"
