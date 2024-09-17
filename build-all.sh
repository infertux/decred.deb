#!/bin/bash

set -euxo pipefail

dcr_version=2.0.4

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

find . -name "*.deb" -exec sha256sum {} \;
find . -name "*.deb" -exec ls -lh {} \;
