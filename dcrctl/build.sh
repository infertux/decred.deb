#!/bin/bash

set -euo pipefail

version=${1:-1.5.0}
iteration=${2:-1}

cd "$(dirname "$0")"

pushd dcrd.git
    git pull
    pushd cmd/dcrctl
        go build -v
    popd
popd

cp -an dcrd.git/cmd/dcrctl/sample-dcrctl.conf dcrctl.conf
diff -u dcrd.git/cmd/dcrctl/sample-dcrctl.conf dcrctl.conf || true
echo "Does the diff look okay? ^C to abort"
read -r

cp -a dcrd.git/cmd/dcrctl/dcrctl .
strip dcrctl

fpm -f --verbose -s dir -t deb \
    --name dcrctl \
    --provides dcrctl \
    --description "Decred dcrctl" \
    --url "https://github.com/decred/dcrd/tree/master/cmd/dcrctl" \
    --license "ISC" \
    --vendor "https://www.decred.org/" \
    --maintainer "Cédric Felizard <cedric@felizard.eu>" \
    --version "${version}" \
    --iteration "${iteration}" \
    --after-install ../create-user.sh \
    --config-files /etc/decred/dcrctl.conf \
    --package dcrctl.deb \
    dcrctl=/usr/bin/ \
    dcrctl.conf=/etc/decred/
