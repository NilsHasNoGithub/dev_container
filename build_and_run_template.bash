#/usr/bin/env bash

set -e

IMAGE_TAG=localhost/dev_container
CONTAINER_NAME=dev_container0

export DOCKER_CMD=${1:-podman}

if ! command -v $DOCKER_CMD &> /dev/null; then
    export DOCKER_CMD=docker
fi


$DOCKER_CMD build -t $IMAGE_TAG .


[ "$($DOCKER_CMD ps -a | grep $CONTAINER_NAME)" ] && $DOCKER_CMD container rm $CONTAINER_NAME 

# Some other interesting mountpoints:
# --mount type=bind,source=$HOME/.zsh_history,target=/home/user/.histfile
# --mount type=bind,source=$HOME/.zsh_history,target=/root/.histfile

$DOCKER_CMD run -it --rm \
    --mount type=bind,source="$(pwd)",target=/home/user/project \
    --name dev_container0 \
    --gpus all \
    $IMAGE_TAG \
    zsh

# $DOCKER_CMD run -it --rm \
#     --mount type=bind,source="$(pwd)",target=/home/user/project \
#     -p 32790:32790 \
#     --name dev_container0 \
#     dev_container \
#     'sudo /usr/bin/sshd -D -p 32790'
