#!/bin/bash

DOCKER_COMPOSE_VERSION=${1:-v2.2.2}
sudo mv /usr/local/bin/docker-compose /usr/local/bin/docker-compose-previous
sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chown root:docker /usr/local/bin/docker-compose
sudo chmod g+rx /usr/local/bin/docker-compose
docker-compose -v
