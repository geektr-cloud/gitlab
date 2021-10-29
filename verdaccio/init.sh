#!/usr/bin/env bash
cd "$(dirname "$0")"

if [ ! -f ./.secret ]; then
  cp template/.secret ./
  vim .secret
fi

source .secret

envsubst < template/config.yaml > config.yaml

docker volume create gitlab_verdaccio_storage

docker-compose up -d
