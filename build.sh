#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

target="${1:-dcrd/dcrd-2.0.4}"
interactive="${2:-}"
container=decred-builder
volume=/root/HOST
channel=bookworm

docker pull debian:${channel}

[ "$(docker ps -qaf "name=${container}")" ] || docker run --name $container -d -t -v "${PWD}:${volume}" debian:${channel}

docker start $container

docker exec $container dpkg --configure -a
docker exec $container bash -c "echo \"deb http://ftp.sg.debian.org/debian ${channel} main\" | tee /etc/apt/sources.list"
docker exec $container bash -c "echo \"deb http://ftp.sg.debian.org/debian ${channel}-backports main\" | tee -a /etc/apt/sources.list"
docker exec $container apt-get update
docker exec $container apt-get upgrade -y
docker exec $container apt-get install -y build-essential devscripts dh-exec vim quilt lintian
docker exec $container apt-get install -y -t ${channel}-backports golang-1.22
docker exec $container apt-get autoremove -y --purge

dir="${volume}/${target}"
package=${target#*/}
package="${package/-/_}*.deb"

if [ "$interactive" ] ; then
    docker exec -ti $container /bin/bash
else
    docker exec --workdir "$dir" $container git config --global --add safe.directory "$dir" # https://github.com/techknowlogick/xgo/issues/154
    docker exec --workdir "$dir" $container debuild -uc -us || docker exec -ti $container /bin/bash

    docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec lintian --info --pedantic {} \;
    docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec dpkg -c {} \;
    docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec ls -lh {} \;
    docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec sha256sum {} \;
fi

sudo chown -R "${USER}:" ./*
