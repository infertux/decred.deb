#!/bin/bash

set -euo pipefail

version=${1:-1.5.0}
iteration=${2:-0}
depends="dcrctl (>= 1.5.0-0)"

cd "$(dirname "$0")"

# git submodule update --remote

pushd dcrd.git
ls -lh
go build -v
popd

cp -an dcrd.git/sampleconfig/sampleconfig.go dcrd.conf
diff -u dcrd.git/sampleconfig/sampleconfig.go dcrd.conf || sleep 3

cp -a dcrd.git/dcrd .
strip dcrd
sha256sum dcrd

fpm -f --verbose -s dir -t deb \
    --name dcrd \
    --provides dcrd \
    --deb-systemd dcrd.service \
    --description "Decred dcrd" \
    --url "https://github.com/decred/dcrd" \
    --license "ISC" \
    --vendor "https://www.decred.org/" \
    --maintainer "Cédric Felizard <cedric@felizard.eu>" \
    --version "${version}" \
    --iteration "${iteration}" \
    --after-install ../create-user.sh \
    --deb-after-purge purge.sh \
    --depends "libc6" \
    --depends "${depends}" \
    --config-files /etc/decred/dcrd.conf \
    --package dcrd.deb \
    dcrd=/usr/bin/ \
    dcrd.conf=/etc/decred/

sha256sum dcrd.deb
