#!/bin/bash

cd "$(dirname "$0")"/..

source etc/tls-refresh/.env

read -rp "What Docker image would you like to use? (tls-refresh-server)" service_image

service_image=${service_image:-tls-refresh-server}

docker inspect --type=image "$service_image" > /dev/null

read -rp "What would you like to name your service? (\"server\")" service_name
read -rp "What port will your service listen on? (9000)" service_port
read -rp "How many instances do you want to run? (2)" service_scale

service_name=${service_name:-server}
service_port=${service_port:-9000}
service_scale=${service_scale:-2}

{
  echo "domain=$domain";
  echo "email=$email";
  echo "service_image=$service_image";
  echo "service_name=$service_name";
  echo "service_port=$service_port";
  echo "service_scale=$service_scale";
} > etc/tls-refresh/.env

echo $'version: \'3.8\'

networks:
  tls-refresh:
    name: tls-refresh

services:
  certbot:
    image: tls-refresh-certbot
    networks:
      - tls-refresh
    volumes:
      - $PWD/etc/haproxy/certs:/etc/haproxy/certs
      - $PWD/etc/letsencrypt/renewal-hooks/deploy:/etc/letsencrypt/renewal-hooks/deploy:ro
      - $PWD/etc/tls-refresh:/etc/tls-refresh:ro

  gateway:
    image: haproxy:2.4.0
    depends_on:
      - certbot
      - '"$service_name"'
    networks:
      - tls-refresh
    ports:
      - 80:80
      - 443:443
    restart: always
    volumes:
      - $PWD/etc/haproxy:/usr/local/etc/haproxy:ro
      - $PWD/etc/tls-refresh:/etc/tls-refresh:ro

  '"$service_name"':
    image: '"$service_image"'
    networks:
      - tls-refresh
    restart: always' > docker-compose.yml

echo $'global
  daemon
  log 127.0.0.1 local0 notice
  ssl-default-bind-options ssl-min-ver TLSv1.2
  stats socket ipv4@0.0.0.0:9999 level admin
  stats timeout 2m

defaults
  log     global
  mode    http
  option  httplog
  timeout connect 5s
  timeout client 1m
  timeout http-request 10s
  timeout server 1m

frontend gateway
  mode http
  bind *:80
  bind *:443 ssl crt /usr/local/etc/haproxy/certs/'"$domain"'.pem
  acl is_certbot path_beg /.well-known/acme-challenge/
  http-request redirect scheme https code 301 if !{ is_certbot } !{ ssl_fc }
  use_backend certbot if is_certbot
  default_backend '"$service_name"'

backend certbot
  mode http
  server server1 tls-refresh_certbot_1:8080

backend '"$service_name"'
  mode http
'"$(for i in $(seq 1 "$service_scale"); do echo '  server server'"$i"' tls-refresh_'"$service_name"_"$i":"$service_port"; done)" > etc/haproxy/haproxy.cfg
