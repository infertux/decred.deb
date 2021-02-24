#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

target="${1:-dcrd/dcrd-1.6.1}"
interactive="${2:-}"
container=decred-builder
volume=/root/HOST
image=debian:unstable

docker pull $image

[ "$(docker ps -qaf "name=${container}")" ] || docker run --name $container -d -t -v "${PWD}:${volume}" $image

docker start $container

docker exec $container dpkg --configure -a
docker exec $container bash -c 'echo "deb http://ftp.fr.debian.org/debian unstable main" | tee /etc/apt/sources.list' # XXX: the global mirror often times out for me so using a local mirror instead
docker exec $container apt-get update
docker exec $container apt-get upgrade -y
docker exec $container apt-get install -y devscripts dh-exec vim quilt lintian
docker exec $container apt-get install -y -t unstable golang
docker exec $container apt-get autoremove -y --purge

docker exec $container go version

dir="${volume}/${target}"
package=${target#*/}
package="${package/-/_}*.deb"

if [ "$interactive" ] ; then
    docker exec -ti $container /bin/bash
else
    docker exec --workdir "$dir" $container debuild -uc -us || docker exec -ti $container /bin/bash

    docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec lintian --info --pedantic {} \;
    docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec dpkg -c {} \;
    docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec ls -lh {} \;
    docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec sha256sum {} \;
fi

sudo chown -R "${USER}:" ./*
