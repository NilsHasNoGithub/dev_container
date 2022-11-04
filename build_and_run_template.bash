#/usr/bin/env bash

set -e

IMAGE_TAG=dev_container

export DOCKER_CMD=${1:-podman}

if ! command -v $DOCKER_CMD &> /dev/null; then
    export DOCKER_CMD=docker
fi


$DOCKER_CMD build -t $IMAGE_TAG .

$DOCKER_CMD run -it --rm \
    --mount type=bind,source="$(pwd)",target=/home/user/project \
    --name dev_container0 \
    $IMAGE_TAG \
    zsh

# $DOCKER_CMD -it --rm \
#     --mount type=bind,source="$(pwd)",target=/home/user/project \
#     -p 32790:32790 \
#     --name dev_container0 \
#     dev_container \
#     'sudo /usr/bin/sshd -D -p 32790'
