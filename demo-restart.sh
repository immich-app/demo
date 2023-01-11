#!/bin/bash

set -ex

cd /home/ubuntu/immich
sudo iptables -A INPUT -p tcp --dport 80 -j DROP

docker-compose -f docker/docker-compose.yml pull
docker-compose -f docker/docker-compose.yml down -v
docker-compose -f docker/docker-compose.yml up -d immich-server

until curl 127.0.0.1:3001/server-info/ping; do sleep 1; done

curl --location --request POST '127.0.0.1:3001/auth/admin-sign-up' \
--header 'Content-Type: application/json' \
--data-raw '{
    "email": "demo@immich.app",
    "password": "demo",
    "firstName": "John",
    "lastName": "Doe"
}'

docker-compose -f docker/docker-compose.yml up -d

sudo iptables -D INPUT -p tcp --dport 80 -j DROP

docker run --rm -v /home/ubuntu/immich/demo/library:/import ghcr.io/immich-app/immich-cli:latest upload --email demo@immich.app --password demo --server https://demo.immich.app/api -d /import -y
docker system prune -f
