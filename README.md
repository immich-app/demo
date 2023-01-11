# Demo
This repo contains the setup for the demo instance at https://demo.immich.app/  
You probably don't want to use this yourself. Instead, check out the install guide at https://docs.immich.app/docs/install/docker-compose

To deploy:
1. Have a server with docker and docker-compose setup, and exiftool installed
2. Pull this repository

Start the server:

3. `cd docker`
4. `echo "JWT_SECRET=$(openssl rand -base64 48)" > secret.env.test`
5. `docker-compose up -d`

Prepare the dummy library:

6. `./library/run-geocoder.sh`
7. `./library/download-library.sh`
8. Check if the geocoder is initialized: `docker logs geocoder` (if it isn't, wait)
9. `./library/create-dummy-gps.py ./library/images`
10. `docker stop geocoder`

Restart the demo and upload the dummy library:

11. `./demo-restart.sh`

Set up the regular restart:

12. `crontab ./cron`
