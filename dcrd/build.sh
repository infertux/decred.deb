#!/bin/bash

set -euo pipefail

version=${1:-1.5.0}
iteration=${2:-1}

cd "$(dirname "$0")"

pushd dcrd.git
    git pull
    go build -v
popd

cp -an dcrd.git/sampleconfig/sampleconfig.go dcrd.conf
diff -u dcrd.git/sampleconfig/sampleconfig.go dcrd.conf || true
echo "Does the diff look okay? ^C to abort"
read -r

cp -a dcrd.git/dcrd .
strip dcrd

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
    --depends "dcrctl=${version}" \
    --config-files /etc/decred/dcrd.conf \
    --package dcrd.deb \
    dcrd=/usr/bin/ \
    dcrd.conf=/etc/decred/
