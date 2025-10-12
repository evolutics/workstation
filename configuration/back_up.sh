#!/bin/bash

set -o errexit -o nounset -o pipefail

cd -- "$(dirname -- "$0")"
FREQUENCY="${PWD##*.}"
readonly FREQUENCY

if /usr/bin/rsnapshot "${FREQUENCY}"; then
  if (("${RANDOM}" % 7 == 0)); then
    su '{{ user }}' --command "notify-send 'Backup ${FREQUENCY} succeeded'"
  fi
else
  su '{{ user }}' --command \
    "notify-send 'Backup ${FREQUENCY} failed' 'See: {{ rsnapshot_log }}'"
  exit 1
fi
