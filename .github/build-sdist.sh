#!/usr/bin/env bash

# When making changes to this script, please run 'shellcheck' on it in order
# to maintain best practices. See: https://github.com/koalaman/shellcheck


set -e  # Exit immediately if any command line fails.

quit () {
  echo "Quitting on error: $*"
  exit 1
}

run () {
  # Use `set -x` to run the given command, so it gets printed to the console.
  set -x
  "$@"
  { ecode="$?"; set +x; } 2>/dev/null
  return "${ecode}"
}

build_sdist() {
  [ -z "${LIBGPIOD_VERSION}" ] && quit 'Missing LIBGPIOD_VERSION environment variable'
  pushd bindings/python
  # Read the [build-system].requires dependency list from pyproject.toml.
  readarray -t packages < <(yq -p toml '.build-system.requires|join("\n")' < pyproject.toml)
  run python -m pip install "${packages[@]}"
  run python setup.py sdist
  popd
  mkdir -p gpiod-sdist
  run tar -C gpiod-sdist -xzf bindings/python/dist/gpiod-*.tar.gz --strip-components 1
}

build_sdist
