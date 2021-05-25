#!/bin/bash

cd "$(dirname "$0")"/..

source etc/tls-refresh/.env

docker-compose up -d --scale "$service_name"="$service_scale"
