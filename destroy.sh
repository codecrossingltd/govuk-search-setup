#!/usr/bin/env bash
set -eoux pipefail

# Completely destroy the Docker environment

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images -q)
docker volume prune
docker network prune
