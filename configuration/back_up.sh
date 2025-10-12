#!/bin/bash

set -o errexit -o nounset -o pipefail

notify_user() {
  local -r message="$1"
  su '{{ user }}' --command "notify-send '${message}'"
}

main() {
  cd -- "$(dirname -- "$0")"
  local -r frequency="${PWD##*.}"

  if /usr/bin/rsnapshot "${frequency}"; then
    if (("${RANDOM}" % 7 == 0)); then
      notify_user "Backup ${frequency} succeeded"
    fi
  else
    notify_user "Backup ${frequency} failed, see: /var/log/rsnapshot.log"
    exit 1
  fi
}

main "$@"
