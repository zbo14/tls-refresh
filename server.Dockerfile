FROM node:14.17.0-alpine

RUN apk update && \
    apk upgrade && \
    adduser -D tls-refresh-server

USER tls-refresh-server

COPY ./server.js /home/tls-refresh-server/index.js

WORKDIR /home/tls-refresh-server

ENTRYPOINT node index
