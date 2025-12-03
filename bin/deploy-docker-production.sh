#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="curamentorapi"

echo "Stopping docker container..."

if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Stopping container: ${CONTAINER_NAME} ..."
  docker stop "${CONTAINER_NAME}"
  echo "Container ${CONTAINER_NAME} stopped."
else
  echo "Container ${CONTAINER_NAME} is not running."
fi

echo "Updating codebase..."

git pull origin master

echo "Building updated container..."

docker build \
  --build-arg BUNDLER_VERSION=2.6.2 \
  -t ${CONTAINER_NAME}:latest \
  --no-cache \
  .

echo "Creating production database..."

docker run --rm \
  --name ${CONTAINER_NAME}-dbcreate \
  --add-host=host.docker.internal:host-gateway \
  --env-file .env.production \
  ${CONTAINER_NAME}:latest \
  bash -lc 'bundle exec rails db:create RAILS_ENV=production'

echo "Migrating schema to production database..."

docker run --rm \
  --name ${CONTAINER_NAME}-dbmigrate \
  --add-host=host.docker.internal:host-gateway \
  --env-file .env.production \
  ${CONTAINER_NAME}:latest \
  bash -lc 'bundle exec rails db:migrate RAILS_ENV=production'

echo "Starting container..."

# If the container exists (running or stopped), remove it
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Removing existing container: ${CONTAINER_NAME}"
  docker rm -f "${CONTAINER_NAME}"
fi

echo "Starting ${CONTAINER_NAME} ..."
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  --add-host=host.docker.internal:host-gateway \
  --env-file .env.production \
  -p 127.0.0.1:8080:3000 \
  ${CONTAINER_NAME}:latest

echo "Restarting nginx..."
sudo systemctl restart nginx
