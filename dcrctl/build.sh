#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

pushd dcrd.git/cmd/dcrctl
go build -v
popd

cp -an dcrd.git/cmd/dcrctl/sample-dcrctl.conf dcrctl.conf
diff -u dcrd.git/cmd/dcrctl/sample-dcrctl.conf dcrctl.conf || sleep 3

cp -a dcrd.git/cmd/dcrctl/dcrctl .
strip dcrctl
sha256sum dcrctl
