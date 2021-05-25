# tls-refresh

Auto-generate and renew your TLS certificates for [HAProxy](https://www.haproxy.org/) using [certbot](https://certbot.eff.org/)!

## Overview

HAProxy is very handy as a reverse proxy and well-suited for load balancing across several backend servers. It can also perform TLS termination so there's no need to update TLS certificates on each backend server. I thought it might be cool to have a Dockerized HAProxy + certbot configuration that would auto-renew certificates and leverage HAProxy's [runtime API](https://www.haproxy.com/blog/dynamic-configuration-haproxy-runtime-api/) to update TLS credentials without restarting the service and introducing downtime.

## Dependencies

`tls-refresh` should work across UN\*X systems 🤞

* [Docker](https://docs.docker.com/get-docker/)
* [Compose](https://docs.docker.com/compose/install/)

## Usage

### Setup

`$ ./tls-refresh setup`

This command does the following:

* Prompts you for domain and email address
* Customizes environment file and HAProxy TLS settings
* Builds Docker images for certbot and demo server
* Generates self-signed (placeholder) certificate for HAProxy
* Specifies weekly cron job to check certificate renewal

Your domain and email address are stored in `./etc/tls-refresh/.env` (gitignored).

### Configuration

`tls-refresh` ships with a NodeJS HTTP server that responds to requests with a short note about this project. This is meant for testing and demo purposes to ensure that certificate generation and renewal works.

To substitute your own web service, run `./tls-server configure`. This command prompts for the following service information:

* Docker image (Default: tls-refresh-server)
* Name (Default: "server")
* Listening port (Default: 9000)
* Scale / # of instances (Default: 2)

It then stores this information in `./etc/tls-refresh/.env` and modifies the `docker-compose.yml` and `./etc/haproxy/haproxy.cfg` files accordingly.

Further configuration of `docker-compose.yml` or `haproxy.cfg` must be done manually. Please refer to the appropriate [documentation](#Resources).

### Start

Start the HAProxy gateway, certbot, and web server!

`$ ./tls-refresh start`

### Stop

Stop and remove the running containers.

`$ ./tls-refresh stop`

## Design

Each service (i.e. HAProxy, certbot, web server) runs in a Docker container on the Docker network, `tls-refresh`. The entire configuration is defined in the aforementioned `docker-compose.yml` file.

This configuration has a few advantages:

* We don't need to install any dependencies locally besides Docker + Compose
* The services can communicate with each other via DNS names
* HAProxy is the only service with exposed ports; everything else sits behind it

A weekly cron job runs cerbot in a Docker container on the `tls-refresh` network to renew the TLS certificate, if need be. On successful renewal, a [deploy hook](./etc/letsencrypt/renewal-hooks/deploy/update-haproxy) executes and updates HAProxy's TLS settings to use the new certificate.

**Note:** the certbot containers *aren't* persistent like the HAProxy gateway or web server; they should create or renew the certificate and then exit.

## Contributing

Want to make `tls-refresh` better?

[Open an issue](https://github.com/zbo14/tls-refresh/issues/new) or [create a pull request](https://github.com/zbo14/tls-refresh/compare/develop...) and let's take it from there!

## Resources

* https://certbot.eff.org/docs/using.html
* https://cbonte.github.io/haproxy-dconv/2.4/configuration.html
* https://docs.docker.com/compose/
* https://www.haproxy.com/blog/dynamic-ssl-certificate-storage-in-haproxy/
