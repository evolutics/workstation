#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

main() {
  local -r script_folder="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local -r project_folder="$(dirname "${script_folder}")"

  pushd "${project_folder}"

  local -r image_id="$(docker build --quiet \
    --build-arg ansible_lint=4.2.0 \
    --build-arg git=2.24.1 \
    --build-arg gitlint=0.12.0 \
    --build-arg hunspell=1.7.0 \
    --build-arg prettier=1.19.1 \
    https://github.com/evolutics/code-cleaner-buffet.git#0.7.0)"
  docker run --rm --volume "$(pwd)":/workdir "${image_id}" ci/check.sh

  popd
}

main "$@"
