#!/bin/bash

set -ex

cd /home/ubuntu/demo
sudo iptables -A INPUT -p tcp --dport 80 -j DROP

docker compose pull
docker compose down -v
docker compose up -d immich-server

until curl http://127.0.0.1:3001/api/server-info/ping; do sleep 1; done

# skip admin sign up
curl \
  -L \
  -X POST 'http://127.0.0.1:3001/api/auth/admin-sign-up' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "demo@immich.app",
    "password": "demo",
    "name": "John Doe"
}'

# login
accessToken=$(curl \
  -L \
  -X POST http://127.0.0.1:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{ "email": "demo@immich.app", "password": "demo" }' \
  | jq -r '.accessToken' \
)

# skip admin onboarding
curl \
  -L \
  -X POST 'http://127.0.0.1:3001/api/server-info/admin-onboarding' \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${accessToken}" \
  -d '{}'

# create api key
apiKey=$(curl \
  -X POST 127.0.0.1:3001/api/api-key \
  -H "Content-Type: application/json" \
  -H "$header" \
  -d '{"name": "Demo controller"}' \
  | jq -r '.secret' \
)

# set welcome message
# "This is a demo instance of Immich. It is regularly reset. 
#   <br>Email: <i>demo@immich.app</i><br>Password: <i>demo</i>
#   <br><br><b style='color: red'>Due to abuse, uploads to this instance are disabled.</b>"

docker compose up -d

sudo iptables -D INPUT -p tcp --dport 80 -j DROP

docker run --rm -v /home/ubuntu/demo/images:/import --network demo_default ghcr.io/immich-app/immich-cli:latest upload --key "$apiKey" --server http://immich-server:3001/api -d /import -y
docker system prune -f
