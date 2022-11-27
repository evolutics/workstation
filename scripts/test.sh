#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

main() {
  local -r script_folder="$(dirname "$(readlink --canonicalize "$0")")"
  cd "$(dirname "${script_folder}")"

  git ls-files -z | xargs -0 nix run --no-write-lock-file \
    github:evolutics/travel-kit -- check --

  nix run nixpkgs#ansible-lint
}

main "$@"
