# tls-refresh

Auto-generate and refresh your TLS certificates for HAProxy using [certbot](https://certbot.eff.org/)!

## Dependencies

`tls-refresh` should work across UN\*X systems 🤞

* [Docker](https://docs.docker.com/get-docker/)
* [Compose](https://docs.docker.com/compose/install/)

## Usage

### Configuration

`tls-refresh` ships with a NodeJS HTTP server that responds to requests with a short note about this project. This is only meant for testing and demo purposes.

You can modify the `services > server` section in the `docker-compose.yml` file to use another HTTP server and name it something more descriptive.

Make sure to modify the final `backend` block in `./etc/haproxy/haproxy.cfg` so it references the correct DNS name for your web service.

TODO: add command for this

### Setup

`$ ./tls-refresh setup`

This command does the following:

* Prompts you for domain and email address
* Customizes environment file and HAProxy TLS settings
* Builds Docker images for certbot and demo server
* Generates self-signed (placeholder) certificate for HAProxy
* Specifies weekly cron job to check certificate renewal

### Start

Start the HAProxy gateway, certbot, and the demo server!

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
* https://www.haproxy.com/blog/dynamic-ssl-certificate-storage-in-haproxy/
