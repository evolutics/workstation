#!/bin/bash

set -o errexit -o nounset -o pipefail

cd -- "$(dirname -- "$0")/.."

nix run --no-write-lock-file github:evolutics/travel-kit
