#!/bin/bash

cd "$(dirname "$0")"/..

source etc/tls-refresh/.env

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
