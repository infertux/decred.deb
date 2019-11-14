#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

version=1.5.0

for target in dcrctl dcrd dcrwallet stakepoold; do
    path="${target}/${target}-${version}"
    ./build.sh $path
done
