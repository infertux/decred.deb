# decred.deb

[![.github/workflows/deb.yml](https://github.com/infertux/decred.deb/actions/workflows/deb.yml/badge.svg)](https://github.com/infertux/decred.deb/actions/workflows/deb.yml)

This repository contains everything to generate packages for various Decred software in the .deb format used by Debian and its derivatives such as Ubuntu.

The generated .deb packages can then be installed directly with `dpkg -i pacakge.deb` or published to an APT repository.

## How to use the APT repository

The builds are reproducible and hosted at the APT repository https://deb.cyberbits.eu/decred/

## How to package a new release

See [HACKING.md](./HACKING.md)

## License

`SPDX-License-Identifier: AGPL-3.0-or-later`
