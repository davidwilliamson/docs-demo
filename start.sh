#!/bin/bash

if [ -z "$OAUTH2_PROXY_CLIENT_ID" ]; then
    echo "Missing OAUTH2_PROXY_CLIENT_ID env var"
    exit 1
fi
if [ -z "$OAUTH2_PROXY_CLIENT_SECRET" ]; then
    echo "Missing OAUTH2_PROXY_CLIENT_SECRET env var"
    exit 1
fi
if [ -z "$NGINX_SERVER_NAME" ]; then
    echo "Missing NGINX_SERVER_NAME env var"
    exit 1
fi

docker-compose build
docker-compose up
