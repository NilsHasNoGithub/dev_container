#/usr/bin/env bash

IMAGE_TAG=localhost/dev_container

set -e

script_dir=$(dirname $0)
cd $script_dir

export DOCKER_CMD=${1:-podman}

if ! command -v $DOCKER_CMD &> /dev/null; then
    export DOCKER_CMD=docker
fi


$DOCKER_CMD build -t $IMAGE_TAG .

