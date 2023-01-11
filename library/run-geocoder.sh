#!/bin/bash

set -e

pushd $(mktemp -d)

git clone https://github.com/tomayac/local-reverse-geocoder.git
cd local-reverse-geocoder

docker build -t local-reverse-geocoder .
docker run -d -p 9300:3000 --rm --name geocoder local-reverse-geocoder

popd