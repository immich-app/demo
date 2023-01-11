#!/bin/bash

set -ex

cd /home/ubuntu/demo
sudo iptables -A INPUT -p tcp --dport 80 -j DROP

docker compose pull
docker compose down -v
docker compose up -d immich-server

until curl 127.0.0.1:3001/server-info/ping; do sleep 1; done

curl --location --request POST '127.0.0.1:3001/auth/admin-sign-up' \
--header 'Content-Type: application/json' \
--data-raw '{
    "email": "demo@immich.app",
    "password": "demo",
    "firstName": "John",
    "lastName": "Doe"
}'

docker compose up -d

sudo iptables -D INPUT -p tcp --dport 80 -j DROP

accessToken=$(curl -d '{"email": "demo@immich.app", "password": "demo"}' -H "Content-Type: application/json" -X POST https://immich-demo.bo0tzz.me/api/auth/login | jq -r '.accessToken')
header="Authorization: Bearer ${accessToken}"
apiKey=`curl -d '{"name": "Demo controller"}' -H "Content-Type: application/json" -H $header -X POST https://immich-demo.bo0tzz.me/api/api-key | jq -r '.secret'`

docker run --rm -v /home/ubuntu/demo/images:/import ghcr.io/immich-app/immich-cli:latest upload -key "$apiKey" --server https://demo.immich.app/api -d /import -y
docker system prune -f
