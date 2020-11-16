#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

main() {
  local -r script_folder="$(dirname "$(readlink --canonicalize "$0")")"
  local -r project_folder="$(dirname "${script_folder}")"
  cd "${project_folder}"

  docker run --entrypoint sh --rm --volume "$(pwd)":/workdir \
    evolutics/travel-kit:0.6.0 -c \
    'git ls-files -z | xargs -0 travel-kit check --'

  docker run --rm --volume "$(pwd)":/workdir \
    "$(DOCKER_BUILDKIT=1 docker build --build-arg ansible_lint=4.3.5 --quiet \
      https://github.com/evolutics/code-cleaner-buffet.git#0.14.0)" \
    ansible-lint
}

main "$@"
