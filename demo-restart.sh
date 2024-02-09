#!/bin/bash

set -ex

cd /home/ubuntu/demo
sudo iptables -A INPUT -p tcp --dport 80 -j DROP

docker compose pull
docker compose down -v
docker compose up -d immich-server

until curl 127.0.0.1:3001/api/server-info/ping; do sleep 1; done

curl --location --request POST '127.0.0.1:3001/api/auth/admin-sign-up' \
--header 'Content-Type: application/json' \
--data-raw '{
    "email": "demo@immich.app",
    "password": "demo",
    "name": "John Doe"
}'

docker compose up -d

sudo iptables -D INPUT -p tcp --dport 80 -j DROP

accessToken=$(curl -d '{"email": "demo@immich.app", "password": "demo"}' -H "Content-Type: application/json" -X POST 127.0.0.1:3001/api/auth/login | jq -r '.accessToken')
header="Authorization: Bearer ${accessToken}"
apiKey=`curl -d '{"name": "Demo controller"}' -H "Content-Type: application/json" -H "$header" -X POST 127.0.0.1:3001/api/api-key | jq -r '.secret'`

docker run --rm -v /home/ubuntu/demo/images:/import --network demo_default \
    -e IMMICH_INSTANCE_URL="http://immich-server:3001/api" -e IMMICH_API_KEY="$apiKey" \
    --pull always ghcr.io/immich-app/immich-cli:latest \
    upload -r -h /import
docker system prune -f
