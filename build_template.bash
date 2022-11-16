#/usr/bin/env bash

set -e

IMAGE_TAG=localhost/dev_container

export DOCKER_CMD=${1:-podman}

if ! command -v $DOCKER_CMD &> /dev/null; then
    export DOCKER_CMD=docker
fi


$DOCKER_CMD build -t $IMAGE_TAG .

