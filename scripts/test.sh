#!/bin/bash

set -o errexit -o nounset -o pipefail

main() {
  local -r script_folder="$(dirname "$(readlink --canonicalize "$0")")"
  cd "$(dirname "${script_folder}")"

  nix run --no-write-lock-file github:evolutics/travel-kit
}

main "$@"
