#!/bin/sh

# Script to install lua rocks and nvim plugins required for running tests

set -eux

unset CDPATH

main() {
  # Change into script parent directory
  cd -P -- "$(dirname -- "$0")/.."
  install_rocks
  install_plugins
}

install_rocks() {
  while read rock; do
    if [ "${rock}" = "${rock###}" ]; then
      luarocks --lua-version=5.1 install ${rock}
    fi
  done < test_rocks.txt
}

install_plugins() {
  oldpwd="${PWD}"
  while read plugin_repo; do
    cd fixtures/plugins
    if [ "${plugin_repo}" = "${plugin_repo###}" ]; then
      clone_or_pull "${plugin_repo}"
    fi
    cd -- "${oldpwd}"
  done < test_plugins.txt
}

clone_or_pull() {
  repo="$1"
  workdir="${repo##*/}"
  workdir="${workdir%.git}"

  if [ -d "${workdir}" ]; then
    git -C "${workdir}" pull
  else
    git clone "${repo}"
  fi
}

main
