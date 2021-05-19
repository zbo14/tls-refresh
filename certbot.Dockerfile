FROM debian:buster

COPY ./scripts/entrypoint.sh /entrypoint.sh

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y certbot socat

ENTRYPOINT bash /entrypoint.sh
