# decred.deb

This repository contains scripts to generate packages for various Decred software in the .deb format used by Debian and its derivatives such as Ubuntu.
The script `./build.sh` takes in a target package to build then spawns a Docker container to run `debuild` and other linting tools.
The generated .deb package can then be installed directly with `dpkg -i pacakge.deb` or published to an APT repository.
The builds are reproducible and hosted at the APT repository https://deb.cyberbits.eu/decred/

## License

AGPLv3+
