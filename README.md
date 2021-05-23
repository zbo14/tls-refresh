# tls-refresh

Auto-generate and refresh your TLS certificates for HAProxy using [certbot](https://certbot.eff.org/)!

## Dependencies

`tls-refresh` should work across UN\*X systems.

* [Docker](https://docs.docker.com/get-docker/)
* [Compose](https://docs.docker.com/compose/install/)

## Usage

### Setup

`$ ./tls-refresh setup`

This command does the following:

* Prompts you for domain and email address
* Customizes environment file and HAProxy TLS configuration
* Builds Docker images for certbot and demo server
* Generates self-signed (placeholder) certificate for HAProxy
* Specifies weekly cronjob to check certificate renewal

### Start

Start the HAProxy gateway, certbot, and the demo server!

`$ ./tls-refresh start`

### Stop

Stop and remove the running containers.

`$ ./tls-refresh stop`

## Design

TODO

## Contributing

TODO

## Resources

* https://certbot.eff.org/docs/using.html
* https://www.haproxy.com/blog/dynamic-ssl-certificate-storage-in-haproxy/
