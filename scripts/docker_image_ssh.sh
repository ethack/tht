#!/bin/bash

if [ $# -eq 0 ]; then
  cat <<EOF
Transfer a docker image to a remote system over SSH.

  Usage: $0 <docker image> <ssh args>
    <docker image>  the name of the image to transfer
    <ssh args>      all arguments are passed through to ssh to establish the connection
EOF
  exit 1
fi

exists () {
  command -v $1 >/dev/null 2>&1
}

# note: include tag to exclude all intermediate stage layers
# drop tag to transfer all stages and tags
IMAGE="$1"
shift

if exists pv && exists jq; then
  # display nice progress bar
  docker image save "$IMAGE" | pv --size $(docker image inspect "$IMAGE" | jq '.[].Size') | ssh -C "$@" docker image load
else
  docker image save "$IMAGE" | ssh -C "$@" docker image load
fi