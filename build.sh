#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

target="${1:-dcrd/dcrd-1.5.0}"
container=deb-builder
volume=/root/HOST

docker pull debian:unstable

[ "$(docker ps -qf "name=${container}")" ] || docker run --name $container -d -t -v "${PWD}:${volume}" debian:unstable

docker exec $container apt-get update
docker exec $container apt-get upgrade -y
docker exec $container apt-get install -y devscripts dh-exec vim quilt lintian
docker exec $container apt-get autoremove -y --purge

dir="${volume}/${target}"
package=${target#*/}
package="${package/-/_}*.deb"

docker exec --workdir "$dir" $container debuild || docker exec -ti $container /bin/bash

docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec lintian --info --pedantic {} \;
docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec dpkg -c {} \;
docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec ls -lh {} \;
docker exec --workdir "$dir" $container find .. -type f -name "$package" -exec sha256sum {} \;

# docker exec --workdir "$dir" $container find dist -type f -name "$package" -exec dpkg -i {} \;
# docker exec $container dpkg -L $package_name
# docker exec $container dpkg -V $package_name

sudo chown -R "${USER}:" ./*

# docker stop $container
