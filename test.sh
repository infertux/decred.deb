#!/bin/bash

set -euo pipefail

for suite in debian-stretch debian-buster; do
    gitlab-runner exec docker $suite
done
