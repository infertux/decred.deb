# decred.deb

This repository contains everything to generate packages for various Decred software in the .deb format used by Debian and its derivatives such as Ubuntu.
The generated .deb packages can then be installed directly with `dpkg -i pacakge.deb` or published to an APT repository.
The builds are reproducible and hosted at the APT repository https://deb.cyberbits.eu/decred/

## How to use the APT repository

```bash
# echo "deb https://deb.cyberbits.eu/decred/ trixie main" | sudo tee /etc/apt/sources.list.d/decred.list
# apt update
# apt install dcrd dcrwallet
```

## License

AGPLv3+
