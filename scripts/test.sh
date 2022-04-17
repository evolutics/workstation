#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

main() {
  local -r script_folder="$(dirname "$(readlink --canonicalize "$0")")"
  cd "$(dirname "${script_folder}")"

  docker run --entrypoint sh --rm --volume "${PWD}":/workdir \
    evolutics/travel-kit:0.7.0 -c \
    'git ls-files -z | xargs -0 travel-kit check --'

  docker run --rm --volume "${PWD}":/workdir \
    "$(DOCKER_BUILDKIT=1 docker build --build-arg ansible_lint=5.3.1 --quiet \
      https://github.com/evolutics/code-cleaner-buffet.git#0.17.0)" \
    ansible-lint
}

main "$@"
