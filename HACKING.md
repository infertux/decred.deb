## How to package a new release

```bash
# download the following file from https://github.com/decred/decred-binaries/releases:
# decred-linux-amd64-vX.Y.Z.tar.gz

pushd decred
tar xvf decred-linux-amd64-vX.Y.Z.tar.gz
rm decred-linux-amd64-vX.Y.Z.tar.gz
pushd decred-linux-amd64-vX.Y.Z/debian
vim -p changelog copyright # bump version, copyright year, etc.
popd
popd
vim -p .github/workflows/deb.yml # bump version
git add -A
git status
git commit
```
