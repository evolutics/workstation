#!/bin/bash

set -o errexit -o nounset -o pipefail

if /usr/bin/rsnapshot '{{ frequency }}'; then
  if (("${RANDOM}" % 7 == 0)); then
    su '{{ user }}' --command 'notify-send "Backup {{ frequency }} succeeded"'
  fi
else
  su '{{ user }}' --command \
    'notify-send "Backup {{ frequency }} failed" "See: {{ rsnapshot_log }}"'
  exit 1
fi
