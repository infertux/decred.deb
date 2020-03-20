#!/bin/bash

set -euxo pipefail

dcr_version=1.5.1
stakepoold_version=1.5.0

cd "$(dirname "$0")"

build() {
    local target=$1
    local version=$2

    path="${target}/${target}-${version}"
    ./build.sh "$path"
}

for dcr in dcrctl dcrd dcrwallet; do
    build $dcr $dcr_version
done

build stakepoold $stakepoold_version

find . -name "*.deb" -exec sha256sum {} \;
find . -name "*.deb" -exec ls -lh {} \;
