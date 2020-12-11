#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

target="${1:-dcrd/dcrd-1.6.0}"
interactive="${2:-}"
container=deb-builder
volume=/root/HOST

docker pull debian:unstable

[ "$(docker ps -qaf "name=${container}")" ] || docker run --name $container -d -t -v "${PWD}:${volume}" debian:unstable

docker start $container

docker exec $container dpkg --configure -a
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
