#!/usr/bin/env bash
cd "$(dirname "$0")"

docker volume create gitlab_caddy_data
docker volume create gitlab_caddy_logs

docker-compose up -d
