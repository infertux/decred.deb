#!/bin/bash

set -euxo pipefail

# Install dependencies for build.sh
apt-get update
apt-get install -y git curl systemd-sysv lintian

# Install Go
gotarball="go1.13.3.linux-amd64.tar.gz"
curl -o ${gotarball} https://dl.google.com/go/${gotarball}
tar -C /usr/local -xzf ${gotarball}
export PATH=$PATH:/usr/local/go/bin

# Install FPM
apt-get install -y ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

# Build and install the .deb packages
pushd dcrctl
./build.sh
lintian -i dcrctl.deb
dpkg -i dcrctl.deb
popd

pushd dcrd
./build.sh
lintian -i dcrd.deb
dpkg -i dcrd.deb
popd

echo "Packages installed successfully"
