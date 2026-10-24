#!/usr/bin/env bash

# usage: makerel.sh X.Y.Z

set -euo pipefail

# we're in `./scripts`, we need to be in the root
cd "$(dirname "$0")/.."

if [[ $# -eq 0 ]]; then
  echo "You didn't give a version!" >&2
  exit 1
fi

# Files to actually include in the archives
release_files=(polyversal README.md LICENSE docs/)

version=${1#v}  # vX.Y.Z -> X.Y.Z

# Guard the sed clause from nefarious slashes or hyphens
# (or anything that's not x.y.z)
if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Version '$version' is not of the form X.Y.Z" >&2
  exit 1
fi

name="Polyversal-v${version}"
release_dir="release/${name}"
echo "Creating v${version} release in ${release_dir} ..."

# Clean up stale files
rm -rf "${release_dir}"{,.zip,.tar.gz}

mkdir -p "${release_dir}"
cp -r --parents "${release_files[@]}" "${release_dir}"

# Stamp the real version into the archived script so it can check for updates
sed -i "s/^readonly VERSION=.*/readonly VERSION=${version}/" "${release_dir}/polyversal"

# Make both archives from inside `release/` so paths start at ${name}/
(cd release && zip -r "${name}.zip" "${name}")
tar -C release -cvzf "${release_dir}.tar.gz" "${name}"
