#!/usr/bin/env bash
cd "$(dirname "$0")"

if [ ! -f ./.secret ]; then
  cp template/.secret ./
  vim .secret
fi

source .secret

envsubst < template/gitlab.rb > gitlab.rb

docker volume create gitlab_gitlab_conf
docker volume create gitlab_gitlab_logs
docker volume create gitlab_gitlab_data

docker-compose up -d
