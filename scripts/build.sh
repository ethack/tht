#!/bin/bash

IMAGE=ethack/tht
DOCKERFILE=Dockerfile
TAG=latest

if [[ -n $1 ]]; then
  FLAVOR="$1"
  DOCKERFILE="flavors/$FLAVOR.dockerfile"
  TAG=$FLAVOR
fi

# change to directory this script is in, following any symlinks
pushd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" > /dev/null
cd ..

docker buildx build \
  --pull \
  --build-arg THT_HASH=$(git describe --always --dirty) \
  --build-arg MAXMIND_LICENSE=$(cat scripts/maxmind_license.txt) \
  -f "$DOCKERFILE" \
  -t "$IMAGE:$TAG" .

# change back to original directory
popd > /dev/null