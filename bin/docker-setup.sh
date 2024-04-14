#!/bin/bash -e

echo " Starting project setup for docker development environment "
if ! command -v 'docker-compose' >/dev/null; then
  echo "Docker Compose not installed. Install before continue."
  exit 1
fi

echo " Docker Compose installed. Proceeding... "
echo " Creating required files and directories "
if [ ! -e ./.env ]; then
  cp ./.env.sample ./.env
else
  echo "Found .env, skipping..."
fi



echo " Docker Compose installed. Proceeding... "
echo " Building containers "
docker-compose build app
echo " Installing dependencies gis_api "
docker-compose run --rm --service-ports app
echo "Setup Finished! Run \"docker-compose up -d\" to get started"
