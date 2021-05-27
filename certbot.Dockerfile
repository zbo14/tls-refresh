FROM debian:buster

COPY ./entrypoint /entrypoint

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y certbot socat sudo && \
    apt-get autoremove -y && \
    adduser --disabled-password --gecos '' certbot && \
    echo "certbot ALL=(ALL) NOPASSWD: /entrypoint" > /etc/sudoers

USER certbot

ENTRYPOINT sudo /entrypoint
