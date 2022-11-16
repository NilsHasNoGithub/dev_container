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

### Some other interesting mountpoints:
# --mount type=bind,source=$HOME/.zsh_history,target=/home/user/.histfile
# --mount type=bind,source=$HOME/.zsh_history,target=/root/.histfile

### shell setup 
$DOCKER_CMD run -it --rm \
    --mount type=bind,source="$(pwd)",target=/project \
    --name $CONTAINER_NAME \
    --gpus all \
    $IMAGE_TAG \
    zsh

### SSH setup
# $DOCKER_CMD run -d --rm \
#     --mount type=bind,source="$(pwd)",target=/project \
#     -p 32790:32790 \
#     --name $CONTAINER_NAME \
#     $IMAGE_TAG \
#     /usr/bin/sshd -D -p 32790

# stop_container() {
#     echo -e "\n\nStopping container\n\n"
#     $DOCKER_CMD stop $CONTAINER_NAME
# }

# trap stop_container SIGINT
# sleep infinity
