#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

git submodule update --remote

container=deb-builder
volume=/root/HOST

#docker run --name $container --rm -d -t -v "${PWD}:${volume}" debian:unstable

docker exec $container apt-get update
docker exec $container apt-get upgrade -y
docker exec $container apt-get install -y debhelper lintian
docker exec $container apt-get install -y systemd-sysv # FIXME: needed?
docker exec $container apt-get install -y golang-go

for package in dcrctl dcrd; do
    dir="${volume}/${package}"

    docker exec --workdir "$dir" $container ./build.sh
    docker exec --workdir "$dir" $container dpkg-buildpackage -b

    # XXX: dpkg-buildpackage puts the .deb in parent dir so we copy it to dist/
    docker exec --workdir "$dir" $container find .. -type f -name "${package}*.deb" -exec mv -v {} dist/ \;

    docker exec --workdir "$dir" $container find dist -type f -name "${package}*.deb" -exec lintian --info --pedantic {} \;
    docker exec --workdir "$dir" $container find dist -type f -name "${package}*.deb" -exec dpkg -i {} \;
    docker exec $container dpkg -L $package
    docker exec $container dpkg -V $package
done

docker stop $container

ls -l dist/*
sha256sum dist/*
