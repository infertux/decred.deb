# decred.deb

This repository contains scripts to generate packages for various Decred software in the .deb format used by Debian and its derivatives such as Ubuntu.
The script `./build.sh` takes in a target package to build then spawns a Docker container to run `debuild` and other linting tools.
The generated .deb package can then be installed directly with `dpkg -i pacakge.deb` or published to an APT repository.
The builds are reproducible and hosted at the APT repository https://deb.cyberbits.eu/decred/

## How to package a new release

```bash
# download these 3 files from https://github.com/decred/decred-binaries/releases:
# decred-linux-amd64-v1.6.0.tar.gz, decred-v1.6.0-manifest.txt and decred-v1.6.0-manifest.txt.asc

pushd dcrd
ln -s ../decred-linux-amd64-v1.6.0.tar.gz dcrd_1.6.0.orig.tar.gz
tar xvf dcrd_1.6.0.orig.tar.gz
mv decred-linux-amd64-v1.6.0 dcrd-1.6.0
cp -ra dcrd-1.5.1/debian dcrd-1.6.0
pushd dcrd-1.6.0/debian
vim -p changelog copyright # bump version, copyright year, etc.
popd
popd
vim -p build{,-all}.sh # bump version
git add -A
./build.sh dcrd/dcrd-1.6.0
git status
git commit
```

## License

AGPLv3+
