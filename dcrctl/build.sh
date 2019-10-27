#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

git submodule update --remote

pushd dcrd.git/cmd/dcrctl
go build -v
popd

cp -an dcrd.git/cmd/dcrctl/sample-dcrctl.conf dcrctl.conf
diff -u dcrd.git/cmd/dcrctl/sample-dcrctl.conf dcrctl.conf || sleep 3

cp -a dcrd.git/cmd/dcrctl/dcrctl .
strip dcrctl
sha256sum dcrctl

set -x

container=deb-builder
volume=/root/HOST
docker run --name $container --rm -d -t -v "${PWD}:${volume}" debian:unstable
docker exec $container apt-get update
docker exec $container apt-get upgrade -y
docker exec $container apt-get install -y debhelper
docker exec --workdir $volume $container dpkg-buildpackage -b

# XXX: dpkg-buildpackage outputs the .deb in parent dir so we need to copy it that way
docker exec --workdir $volume $container ls -l ..
docker exec --workdir $volume $container find .. -type f -name "*.deb" -exec cp -av "{}" dist/ \;
docker stop $container

ls -l dist/*
sha256sum dist/*
