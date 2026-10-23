#!/usr/bin/env bash

# usage: gen-pkgbuild.sh VERSION

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "You didn't give a version!" >&2
    exit 1
fi

# We're in ./scripts, need to be in root
cd "$(dirname "$0")/.."

version=${1#v}

# Guard the sed clause from nefarious slashes or hyphens
# (or anything that's not x.y.z)
if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Version '$version' is not of the form X.Y.Z" >&2
    exit 1
fi

sed "s/^pkgver=.*/pkgver=$version/" aur/PKGBUILD > PKGBUILD
