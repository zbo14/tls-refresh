#!/bin/bash

cd "$(dirname "$0")"/..

echo "Building 'tls-refresh-certbot' image..."

docker build \
  --dockerfile certbot.Dockerfile \
  --no-cache \
  -t tls-refresh-certbot \
  .

echo "Built 'tls-refresh-certbot' image"
echo "Building 'tls-refresh-server' image..."

docker build \
  --dockerfile server.Dockerfile \
  --no-cache \
  -t tls-refresh-server \
  .

echo "Built 'tls-refresh-server' image"
echo "Creating 'tls-refresh' docker network"

docker network create tls-refresh

echo "Created 'tls-refresh' docker network"
