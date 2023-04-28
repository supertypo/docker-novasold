#!/bin/sh

REPO_URL=https://github.com/NovaSolNetwork/NovaSol

VERSION=$1
NOVASOL_VERSION=$(echo $VERSION | grep -oP ".*(?=_.+)")
PUSH=$2

set -e

if [ -z "$VERSION" -o -z "$NOVASOL_VERSION" ]; then
  echo "Usage ${0} <novasol-version_buildnr> [push]"
  echo "Example: ${0} v1.0.0.0_1"
  exit 1
fi

docker build --pull --build-arg VERSION=${NOVASOL_VERSION} --build-arg REPO_URL=${REPO_URL} -t supertypo/novasold:${VERSION} $(dirname $0)
docker tag supertypo/novasold:${VERSION} supertypo/novasold:latest

if [ "$PUSH" = "push" ]; then
  docker push supertypo/novasold:${VERSION}
  docker push supertypo/novasold:latest
fi

