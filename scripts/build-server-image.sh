#!/bin/bash

cd "$(dirname "$0")"/..

echo "Building 'tls-refresh-server' image..."

docker build \
  -f server.Dockerfile \
  --no-cache \
  -t tls-refresh-server \
  .

echo "Built 'tls-refresh-server' image"
