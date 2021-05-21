#!/bin/bash

cd "$(dirname "$0")"/..

echo "Building 'tls-refresh-certbot' image..."

docker build \
  -f certbot.Dockerfile \
  --no-cache \
  -t tls-refresh-certbot \
  .

echo "Built 'tls-refresh-certbot' image"
